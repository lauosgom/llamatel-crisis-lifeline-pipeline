# Crisis lifeline calls pipeline
## Project Overview
This project builds an End-to-End Data Pipeline to collect and analyze the data from a crisis lifeline in Colombia. The primary objective is to download unstructured data from a webpage, extract information and load it into a clean, performant table in a warehouse to provide actionable business insights regarding demographics of the caller, types of problems, and call outcomes.
## Problem Statement
The Telefono de la Esperanza (Phone of Hope) is a non-governmental organisation dedicated to mental health. One of their main services is a crisis helpline, where people can call for psychological support or simply to be listened to. All calls are answered by an expert who listens and offers advice on next steps. After every call, the expert, or 'orientador', completes a form detailing the nature of the call and the problem, and provides a brief summary of the conversation.

Currently, they are trying to transition to better software and data infrastructure. However, to preserve the old data on their servers, they must download it manually, with each call producing a single PDF. This process is time-consuming as it requires downloading each call individually from 2008 onwards and it is presumed to be more than 20000 calls during the time frame. To facilitate this process, I have designed a web scraper that logs in to the website with the correct credentials and downloads the data in PDF format. The data is stored in a data lake in the form of a Google Cloud Storage bucket. Next, the call information is extracted and a table is built. The data is merged into a raw BigQuery table. The table undergoes through a series of transformation following business rules provided by members of the organization and finaly it serves a a source for a reporting dashboard. The whole process is orchestrated in Prefect and is scheduled to run the first day of every month.

More information about Telefono de la Esperanza here https://telefonodelaesperanza.org/

## Architecture and Technologies
- __Cloud-based Development Environment:__ Codespaces
- __Cloud Platform:__ Google Cloud Platform (GCP)
- __Infrastructure as Code:__ Terraform
- __Workflow Orchestration:__ Prefect
- __Data Lake:__ Google Cloud Storage (GCS)
- __Data Warehouse:__ BigQuery
- __Transformation Layer:__ dbt (Data Build Tool)
- __Visualization:__ Looker Studio

## Project Architecture
![Project architecture diagram](assets/diagram.png)

The whole application is hosted in a e2-micro virtual machine in Google Compute Engine. This is the smallest machine they offer, but it is avaible in the Google Cloud Platform free tier. The load is not vey hard because the flow will only run the first of each month moving forward. The data is aquired using a scraper that logs in the webpage, authenticates and download the pdf for each call in a time frame. The pdf is stored in a temporary folder, but is imediately uploaded to a Google Cloud Storage bucket. Simultaneously, the information in the pdf is extracted usign regular expressions and the resulting dataframe is ingested into a data lake in BigQuery.

After the ingestion, the raw table goes through some transformations in dbt to generate a final table that will be used for the dashboard in Google Looker Studio. The whole pipeline is orchestrated using prefect.

## Project structure
```bash
my-project/  
│ 
├── config/                           # Shared config & secrets references  
│   └── settings.py                   # Env vars, GCS bucket names, BQ IDs, etc.
│
├── ingestion/                        # Steps 1–3: download, extract, upload  
│   ├── scraper.py                    # (1) Download PDFs from webpage  
│   ├── extractor.py                  # (2) Extract data from PDFs → DataFrame  
│   └── uploader.py                   # (3) Upload PDFs to GCS
│ 
├── orchestration/                    # Step 6: Prefect flows & tasks  
│   ├── flows/  
│   │   └── main_flow.py              # Master flow wiring everything together  
│   ├── tasks/  
│   │   ├── scrape_task.py  
│   │   ├── extract_task.py  
│   │   ├── upload_task.py  
│   │   ├── load_task.py  
│   │   └── dbt_task.py  
│   └── deployments/  
│       └── deployment.py             # Prefect deployment config
│ 
├── terraform/                        # Cloud infrastructure  
│   ├── main.tf  
│   ├── variables.tf  
│   ├── outputs.tf  
│  
├── tests/                            # Unit & integration tests - Coming soon  
│   ├── test_scraper.py  
│   ├── test_extractor.py  
│   └── test_loader.py
│
├── transform/                        # Step 5: dbt transformations  
│   ├── dbt_project.yml  
│   ├── profiles.yml  
│   ├── models/  
│   │   ├── staging/                  # Raw → cleaned models  
│   │   └── marts/                    # End table(s) for dashboard  
│ 
├── warehouse/                        # Step 4: BigQuery loading  
│   └── loader.py                     # Merge DataFrame into BQ table  
│  
├── .env.example                      # Template for required env vars  
├── uv.lock  
├── .gitignore
└── README.md  
```
## How to run the project

### Prerequisites
- GCP account with billing enabled
- GCP service account with BigQuery Admin, Storage Admin and Compute Admin roles

### 1. Clone the repository
```bash
git clone https://github.com/lauosgom/data-engineering-zoomcamp-final-project.git
cd data-engineering-zoomcamp-final-project
```
### 2. Store GCP service account keys
```bash
cd terraform/keys/
touch credentials.json
nano credentials.json # Paste your keys
```
## Terraform (Infrastructure as Code)

### 1. Configure Terraform
```bash
cd ..
# Edit terraform.tfvars with your GCP project ID and region
```
### 2. Run Terraform
```bash
terraform init
terraform plan
terraform apply
```
Terraform will create a GCS Bucket (Datalake) named "singular-arbor-401018-calls-bucket" and Bigquery Datasets (Data Warehouse) named "raw", "intermediate" and "marts"
Once your infrastructure is in place, you can move forward and connect to the virtual machine

## VM Setup Guide
```bash
#Note: The VM's external IP changes every time it's destroyed and recreated. Always check it with
gcloud compute instances list
```

### 1. Get VM IP (local machine)
```bash
gcloud compute instances list # note the EXTERNAL_IP, e.g. 104.196.175.70
export VM_IP=104.196.175.70  # set this for convenience
```

### 2. SSH into VM (local machine)
```bash
gcloud compute ssh <worker-name> --zone <worker-zone> # check <worker-name> and <worker-region> in your terraform main
```
### 3. Install system dependencies (run in VM)
```bash
sudo apt-get update -y
sudo apt-get install -y python3-pip git curl tmux postgresql postgresql-contrib
```
### 4. Install uv (VM)
```bash
curl -Lsf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
```

### 5. Clone repo (VM)
```bash
git clone https://github.com/lauosgom/data-engineering-zoomcamp-final-project.git
cd data-engineering-zoomcamp-final-project
```
### 6. Install project dependencies (VM)
```bash
uv sync
```
### 7. Install Playwright browsers for the scraper (VM)
```bash
uv run playwright install chromium
uv run playwright install-deps chromium
```
### 8. Install asyncpg (VM)
```bash
uv add asyncpg
```
### 9. Copy .env file (local machine)
```bash
gcloud compute scp /home/lauosgom/anomaly/data-engineering-zoomcamp-final-project/.env prefect-worker:~/data-engineering-zoomcamp-final-project/.env --zone us-east1-c
```
### 10. Set up dbt (VM)
```bash
cd /home/lauosgom/data-engineering-zoomcamp-final-project/transform
uv add dbt-bigquery
cd ..
```
### 11. Set up dbt profiles (VM)
```bash
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << 'EOF'
llamatel_calls:
  outputs:
    dev:
      dataset: marts
      job_execution_timeout_seconds: 300
      job_retries: 1
      method: service-account-json
      keyfile_json:
        type: service_account
        project_id: singular-arbor-401018
        private_key_id: "{{ env_var('BQ_PRIVATE_KEY_ID') }}"
        private_key: "{{ env_var('BQ_PRIVATE_KEY') }}"
        client_email: "{{ env_var('BQ_CLIENT_EMAIL') }}"
        client_id: "{{ env_var('BQ_CLIENT_ID') }}"
        auth_uri: https://accounts.google.com/o/oauth2/auth
        token_uri: https://oauth2.googleapis.com/token
      location: US
      priority: interactive
      project: singular-arbor-401018
      threads: 1
      type: bigquery
  target: dev
EOF
```
The e2-micro only has 1GB of RAM. When processes need more memory than available, Linux either crashes them or slows to a crawl. A swap file is a section of disk that acts as overflow memory — when RAM fills up, Linux moves less-used data to disk temporarily.
### 12. Set up swap file (VM)
```bash
# check if already exists
swapon --show

# if not, create it
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```
Prefect uses a database to store flow runs, task states, logs and deployment metadata. By default it uses SQLite, which is a simple file-based database. SQLite works fine for single-user desktop apps but has a critical limitation: it uses file-level locking, meaning only one process can write to it at a time. PostgreSQL handles concurrent connections properly — multiple processes can read and write simultaneously without locking. It's the production-grade choice for Prefect even on a small VM.
### 13. Set up PostgreSQL for Prefect (VM)
```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo -u postgres psql -c "CREATE USER prefect WITH PASSWORD 'prefect';"
sudo -u postgres psql -c "CREATE DATABASE prefect OWNER prefect;"
```
### 14. Start Prefect server (VM)
Replace YOUR_VM_IP with the actual external IP from Step 1:
```bash
tmux new-session -d -s prefect-server
tmux send-keys -t prefect-server 'cd /home/lauosgom/data-engineering-zoomcamp-final-project && PREFECT_UI_API_URL=http://YOUR_VM_IP:4200/api PREFECT_API_DATABASE_CONNECTION_URL="postgresql+asyncpg://prefect:prefect@localhost/prefect" .venv/bin/prefect server start --host 0.0.0.0' Enter
sleep 10
```
### 15. Create work pool (VM)
```bash
cd /home/lauosgom/data-engineering-zoomcamp-final-project
PREFECT_API_URL=http://127.0.0.1:4200/api .venv/bin/prefect work-pool create my-work-pool --type process
```
### 16. Start worker (VM)
```bash
tmux new-session -d -s prefect-worker
tmux send-keys -t prefect-worker 'cd /home/lauosgom/data-engineering-zoomcamp-final-project && export $(grep -v "^#" .env | grep -v "GCS_CREDENTIALS_JSON" | grep -v "BQ_PRIVATE_KEY" | xargs) && export GCS_CREDENTIALS_JSON="$(grep GCS_CREDENTIALS_JSON .env | cut -d= -f2-)" && export BQ_PRIVATE_KEY="$(grep BQ_PRIVATE_KEY .env | cut -d= -f2-)" && PREFECT_API_URL=http://127.0.0.1:4200/api .venv/bin/prefect worker start --pool my-work-pool' Enter
```
### 17. Deploy the flow (VM)
```bash
cd /home/lauosgom/data-engineering-zoomcamp-final-project
PREFECT_API_URL=http://127.0.0.1:4200/api .venv/bin/python orchestration/deployments/deployment.py
```
### 18.C onnect local machine to VM's Prefect server (local machine)
Replace YOUR_VM_IP with the actual external IP:
```bash
cd /home/lauosgom/anomaly
uv run --project data-engineering-zoomcamp-final-project prefect config set PREFECT_API_URL=http://YOUR_VM_IP:4200/api
uv run --project data-engineering-zoomcamp-final-project prefect config unset PREFECT_SERVER_ALLOW_EPHEMERAL_MODE
```
### 19. Verify connection (local machine)
```bash
uv run --project data-engineering-zoomcamp-final-project prefect deployment ls
```
### Step 20 — Open UI in browser
http://YOUR_VM_IP:4200

If everything work, you can see the deployment in your browser
<img width="3801" height="631" alt="image" src="https://github.com/user-attachments/assets/1c750ee4-6088-425f-afaa-5014752a2464" />

Then you can run the pipeline with the range of dates you want. A general pipeline looks like this:
<img width="3804" height="761" alt="image" src="https://github.com/user-attachments/assets/6c664d16-fb80-45ca-8c5b-b18a536b17c4" />
Each pdf information is extracted and merged to the warehouse, the pdf is then uploaded to the GCS bucket

You can verify that the tables exist in the bigquery datasets and can make any query to check the data.
<img width="3675" height="1827" alt="image" src="https://github.com/user-attachments/assets/78c0e658-5b93-43ca-808e-0d134c2ffde2" />

## Dashboard - Google Looker Studio

View Dashboard: https://lookerstudio.google.com/s/jtvbRpRUCZg

<img width="944" height="719" alt="image" src="https://github.com/user-attachments/assets/252c72ad-0207-48b9-9e8a-d0b34e7105d4" />


