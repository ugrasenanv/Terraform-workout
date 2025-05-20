#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
cd /home/ubuntu
sudo apt remove -y needrestart
sudo apt update
sudo apt install -y build-essential python3-pip libc-dev python3-dev libpq-dev libcurl4-openssl-dev nginx celery python3-django-celery-beat rabbitmq-server
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
echo 'ubuntu ALL=(ALL:ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ubuntu
sudo python3 -m pip install ansible 
sudo mkdir -p /home/ubuntu/project_name
sudo chown -cR ubuntu:ubuntu /home/ubuntu/
sudo mkdir -pv /var/{log,run}/gunicorn/
sudo chown -cR ubuntu:ubuntu /var/{log,run}/gunicorn/
sudo mkdir -p /var/log/nginx
sudo touch /var/log/nginx/project_name.access.log
sudo touch /var/log/nginx/project_name.error.log
sudo chown -cR ubuntu:ubuntu /var/log/
sudo mkdir -p /var/www/project_name/static
sudo chown -cR ubuntu:ubuntu /var/www/project_name/static
sudo touch /home/ubuntu/.ssh/id_rsa
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
echo "AWS_CLOUDFRONT_DOMAIN=${AWS_CLOUDFRONT_DOMAIN}" >> /home/ubuntu/.env
echo "CLOUDFRONT_DISTRIBUTION_ID=${CLOUDFRONT_DISTRIBUTION_ID}" >> /home/ubuntu/.env
echo "AWS_ACCESS_KEY=${AWS_ACCESS_KEY}" >> /home/ubuntu/.env
echo "AWS_SECRET_KEY=${AWS_SECRET_KEY}" >> /home/ubuntu/.env
echo "BUCKET_NAME=${BUCKET_NAME}" >> /home/ubuntu/.env
echo "regiao_aws=${regiao_aws}" >> /home/ubuntu/.env
echo "DB_HOST=${DB_HOST}" >> /home/ubuntu/.env
echo "DB_NAME=${DB_NAME}" >> /home/ubuntu/.env
echo "DB_USER=${DB_USER}" >> /home/ubuntu/.env
echo "DB_PASS=${DB_PASS}" >> /home/ubuntu/.env
echo "DB_PORT=${DB_PORT}" >> /home/ubuntu/.env
echo "DJANGO_ENV=${DJANGO_ENV}" >> /home/ubuntu/.env
echo "DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}" >> /home/ubuntu/.env
echo "DEFAULT_FILE_STORAGE=${DEFAULT_FILE_STORAGE}" >> /home/ubuntu/.env
echo "BG_REMOVAL_ALLOWED=${BG_REMOVAL_ALLOWED}" >> /home/ubuntu/.env
echo "DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE}" >> /home/ubuntu/.env
echo "AWS_STORAGE_BUCKET_NAME=${AWS_STORAGE_BUCKET_NAME}">> /home/ubuntu/.env
echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASS}" > /home/ubuntu/.pgpass
# Install Certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
export DJANGO_SETTINGS_MODULE=project_name.settings_prod

tee -a /home/ubuntu/psql_backup.sh > /dev/null <<EOT
#!/bin/bash
pg_dump -U project_name_user -F p project_name_db > backup.sql
aws s3 cp backup.sql s3://project_name-quiz-company/backup/backup.sql
EOT

chmod +x /home/ubuntu/psql_backup

tee -a collectstatic.sh > /dev/null <<EOT
#!/bin/bash

# Activate the virtual environment
export DJANGO_SETTINGS_MODULE=project_name.settings_prod
source /home/ubuntu/venv/bin/activate 

# Change to the Django project directory
cd /home/ubuntu/project_name/django/

# Load environment variables from .env file
set -a
source .env
set +a

# Collect static files
python manage.py collectstatic --noinput

# Invalidate all files in the CloudFront distribution 
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
EOT


tee -a /home/ubuntu/psql_backup.sh > /dev/null <<EOT
- hosts: localhost
  tasks:
    - name: Print USER_DB value
      shell: source /home/ubuntu/project_name/django/.env && echo $DB_PASS
      args:
        executable: /bin/bash
      register: db_pass
    - name: backup2
      become: yes
      become_user: ubuntu
      shell: |
        sudo -u postgres pg_dump -U postgres -F p project_namedb > /tmp/backup.sql
      args:
        executable: /bin/bash
      register: backup_result
    - name: Write backup result to log file
      become: yes
      become_user: root
      lineinfile:
        path: "/home/ubuntu/backup/logfile.log"
        line: "{{ ansible_date_time.date }} - {{ ansible_date_time.time }} - {{ backup_result.stdout }}"
        state: present
    - name: Copy backup to S3
      become: yes
      become_user: root
      shell: aws s3 cp /tmp/backup.sql s3://project_name-quiz-company/backup/backup.sql
      args:
        executable: /bin/bash
      register: s3_result

    - name: Write S3 result to log file
      become: yes
      become_user: root
      lineinfile:
        path: "/home/ubuntu/backup/logfile.log"
        line: "{{ s3_result.stdout }}"
        create: yes

    - name: Copy log file to S3
      become: yes
      become_user: root
      shell: aws s3 cp /home/ubuntu/backup/logfile.log s3://project_name-quiz-company/backup/logfile.log
      args:
        executable: /bin/bash
      register: s3_result
EOT

tee -a clone_repo.yml > /dev/null <<EOT
- hosts: localhost
  become: yes
  tasks:
    - name: Installing o python3, virtualenv
      block:
        - apt:
            pkg:
                - python3
                - virtualenv
            update_cache: yes
    - name: Install AWS CLI
      become: yes
      apt:
        name: awscli
        update_cache: yes
        state: present
    - name: Create .ssh directory
      become: yes
      become_user: ubuntu
      file:
        path: /home/ubuntu/.ssh
        state: directory
        mode: '0700'
    - name: Get SSH Key from AWS SSM
      become: yes
      become_user: ubuntu
      shell: aws ssm get-parameter --name "/main_project_name" --query "Parameter.Value" --output text > /home/ubuntu/.ssh/id_rsa
      environment:
        AWS_DEFAULT_REGION: 'eu-west-2'
    - name: Set permissions for SSH Key
      become: yes
      become_user: ubuntu
      file:
        path: /home/ubuntu/.ssh/id_rsa
        mode: '0600'
    - name: Add bitbucket.org to known hosts
      become: yes
      become_user: ubuntu
      shell: ssh-keyscan bitbucket.org >> /home/ubuntu/.ssh/known_hosts
    - name: Ensure /home/ubuntu/project_name is owned by ubuntu
      file:
        path: /home/ubuntu/project_name
        state: directory
        owner: ubuntu
        group: ubuntu
        mode: '0755'
    - name: Git Clone
      become: yes
      become_user: ubuntu
      ansible.builtin.git:
        repo:  "git@bitbucket.org:company/project_name.git"
        dest: /home/ubuntu/project_name
        version: test
    - name: Install Python packages from requirements.txt
      pip:
        requirements: /home/ubuntu/project_name/django/requirements.txt
        virtualenv: /home/ubuntu/venv
EOT
su - ubuntu -c "ansible-playbook clone_repo.yml"

tee -a playbook.yml > /dev/null <<EOT
- hosts: localhost
  become: yes
  vars:
    ansible_python_interpreter: /home/ubuntu/venv/bin/python
  handlers:
    - name: restart postgresql
      become: yes
      become_user: root
      service:
        name: postgresql
        state: restarted
    - name: start rabbitmq
      become: yes
      become_user: root
      service:
        name: rabbitmq-server
        state: started
    - name: start celery and celery beat
      become: yes
      become_user: ubuntu
      shell: |
        cd /home/ubuntu/project_name/django
        source /home/ubuntu/venv/bin/activate
        celery -A project_name worker --loglevel=info
        celery -A project_name beat --loglevel=info
      async: 31536000
      poll: 0
  tasks:
    - name: Install cryptography Python package
      pip:
        name: cryptography
        virtualenv: /home/ubuntu/venv
    - name: Move .env file from /home/ubuntu
      become: yes
      become_user: root
      shell: |
        mv /home/ubuntu/.env /home/ubuntu/project_name/django/.env
    - name: Install PostgreSQL
      become: yes
      apt:
        name: postgresql
        state: present
    - name: Ensure PostgreSQL service is running
      become: yes
      service:
        name: postgresql
        state: started
    - name: Set trust auth for local connections
      become: yes
      become_user: root
      lineinfile:
        path: /etc/postgresql/14/main/pg_hba.conf
        regexp: '^local\s+all\s+all\s+'
        line: 'local   all             all                                     trust'
      notify: restart postgresql
    - name: Activate virtual environment and create database user
      become: yes
      become_user: root
      shell: |
        source /home/ubuntu/project_name/django/.env
        sudo -u postgres createuser --createdb ${DB_USER}
      args:
        executable: /bin/bash
    - name: Activate virtual environment and create database
      become: yes
      become_user: root
      shell: |
        source /home/ubuntu/project_name/django/.env
        sudo -u postgres createdb ${DB_NAME}
      args:
        executable: /bin/bash
    - name: Set owner for the database
      become: yes
      become_user: root
      shell: |
        source /home/ubuntu/project_name/django/.env
        sudo -u postgres psql -c "ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};"
      args:
        executable: /bin/bash
    - name: Set password for database user
      become: yes
      become_user: root
      shell: |
        source /home/ubuntu/project_name/django/.env
        sudo -u postgres psql -c "ALTER USER ${DB_USER} WITH PASSWORD '${DB_PASS}';"
      args:
        executable: /bin/bash
    - name: Allow ubuntu user to access project_namedb
      become: yes
      become_user: root
      lineinfile:
        path: "/etc/postgresql/14/main/pg_hba.conf"
        line: 'local   project_namedb     ubuntu                             trust'
        state: present
      notify: restart postgresql
    - name: Prepare Nginx
      become: yes
      become_user: root
      template:
        src: /home/ubuntu/project_name/django/config/nginx/default.conf
        dest: /etc/nginx/sites-available/project_name
    - name: Enable Nginx site
      become: yes
      become_user: root
      file:
        src: /etc/nginx/sites-available/project_name
        dest: /etc/nginx/sites-enabled/project_name
        state: link
    - name: Check if SSL keys and certificates exist in S3 bucket
      aws_s3:
        bucket: "project_name-quiz-company"
        object: /keys/nginx-certificate.key
        mode: get
        dest: /etc/ssl/private/nginx-certificate.key
      register: s3_result
      ignore_errors: yes

    - name: Check if CSR exists in S3 bucket
      aws_s3:
        bucket: "project_name-quiz-company"
        object: /keys/csr
        mode: get
        dest: /path/to/csr
      register: s3_result
      ignore_errors: yes
    - name: Check if SSL certificate exists in S3 bucket
      aws_s3:
        bucket: "project_name-quiz-company"
        object: /keys/nginx-certificate.pem
        mode: get
        dest: /etc/ssl/certs/nginx-certificate.pem
      register: s3_result
      ignore_errors: yes
    - name: Assing /etc/nginx/ ownership to ubuntu user
      shell: |
        sudo rm -rf /etc/nginx/sites-enabled/default
        sudo chown -cR ubuntu:ubuntu /etc/nginx/
        sudo systemctl start nginx
    - name: Copy Database data from s3 bucket
      become: yes 
      become_user: root
      shell: |
        source /home/ubuntu/project_name/django/.env
        aws s3 cp s3://project_name-quiz-company/backup/backup.sql /home/ubuntu/project_name-db.sql
        export PGPASSWORD="${DB_PASS}"
        psql -U ${DB_USER} -d ${DB_NAME} -h localhost -f /home/ubuntu/project_name-db.sql
      args:
        executable: /bin/bash
      environment:
        PGPASSWORD: "M...6"
    - name: collectstatic
      become: yes
      become_user: ubuntu
      shell: |
        cd /home/ubuntu/project_name/django
        . /home/ubuntu/venv/bin/activate
        source /home/ubuntu/django.env
        python manage.py collectstatic --noinput  
    - name: start gunicorn
      become: yes
      become_user: ubuntu
      shell: |
        cd /home/ubuntu/project_name/django
        . /home/ubuntu/venv/bin/activate
        source /home/ubuntu/project_name/django/.env
        gunicorn -c /home/ubuntu/project_name/django/config/gunicorn/prod.py
    - name: Restart Nginx
      become: yes
      become_user: root
      shell: |
        sudo systemctl restart nginx
    - name: Schedule cron job for backup
      become: yes
      become_user: root
      cron:
        name: "Backup job"
        minute: "0"
        hour: "9,11,16"
        job: "ansible-playbook /home/ubuntu/psql_backup.yml"
    - name: Schedule cron for sending csv files
      become: yes
      become_user: root
      cron:
        name: "Send CSV files"
        minute: "0"
        hour: "1"
        job:  "/home/ubuntu/venv/bin/python /home/ubuntu/project_name/django/manage.py csv_sender"
EOT
su - ubuntu -c "ansible-playbook playbook.yml"


tee -a /home/ubuntu/project_name/ubuntu/reload.sh > /dev/null <<EOT
!#/bin/bash
set -x
aws cloudfront create-invalidation --distribution-id E...M --paths '/*'
sleep 2
sudo pkill gunicorn
cd /home/ubuntu/project_name/
git pull origin test
cd /home/ubuntu/project_name/django/
python manage.py collectstatic --noinput
EOT