# Crisis lifeline calls pipeline
## Project Overview
This project builds an End-to-End Data Pipeline to collect and analyze the data from a crisis lifeline in Colombia. The primary objective is to download unstructured data from a webpage, extract information and load it into a clean, performant table in a warehouse to provide actionable business insights regarding demographics of the caller, types of problems, and call outcomes.
## Problem Statement
The Telefono de la Esperanza (Phone of Hope) is a non-governmental organisation dedicated to mental health. One of their main services is a crisis helpline, where people can call for psychological support or simply to be listened to. All calls are answered by an expert who listens and offers advice on next steps. After every call, the expert, or 'orientador', completes a form detailing the nature of the call and the problem, and provides a brief summary of the conversation.

Currently, they are trying to transition to better software and data infrastructure. However, to preserve the old data on their servers, they must download it manually, with each call producing a single PDF. This process is time-consuming as it requires downloading each call individually from 2008 onwards. To facilitate this process, I have designed a web scraper that logs in to the website with the correct credentials and downloads the data in PDF format. The data is stored in a data lake in the form of a Google Cloud Storage bucket. Next, the call information is extracted and a table is built. The data is merged into a raw BigQuery table. The table undergoes through a series of transformation following business rules provided by members of the organization and finaly it serves a a source for a reporting dashboard. The whole process is orchestrated in Prefect and is scheduled to run the first day of every month.

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
the data is stored in pdf files hosted in a google drive folder
script of extraction using some regex
merge tables into bigquery
dashboard
- have a 'flow' in kestra/prefect to do this every month

medio_contacto:  
codigo_numero:  
codigo_letras:  
total_llamadas:  

llamante_sexo:  
llamante_edad:  
llamante_estado_civil:  
llamante_convive:  
llamante_asiduidad:  
llamante_problema:  
llamante_naturaleza:  
llamante_inicio:  
llamante_actitud_orientador:  
llamante_presentacion:  
llamante_paralenguaje:  
llamante_procedencia:  
llamante_peticion:  
llamante_actitud_problema:  
llamante_llamada_derivada:  

tercero_sexo:  
tercero_edad:  
tercero_estado_civil:  
tercero_convive:  
tercero_relacion:  
tercero_problema:  
tercero_actitud_problema:  

llamada_hora:  
llamada_fecha:  
llamada_resultado:  
llamada_duracion:  
entrevista_clave:  
entrevista_referencia:  
entrevista_hora:  
entrevista_fecha:  

orientador_clave_letras:  
orientador_clave_numero:  
orientador_nivel_ayuda:  
orientador_sentimientos:  
orientador_autoevaluacion:  
orientador_actitudes_equivocadas:  
orientador_satisfaccion_llamante:  

sintesis

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
│   └── modules/  
│       ├── gcs/                      # GCS data lake bucket  
│       └── bigquery/                 # BQ datasets & tables  
│  
├── tests/                            # Unit & integration tests  
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
│   └── tests/
│ 
├── warehouse/                        # Step 4: BigQuery loading  
│   └── loader.py                     # Merge DataFrame into BQ table  
│  
├── .env.example                      # Template for required env vars  
├── uv.lock  
├── Dockerfile                        # Optional: containerized Prefect worker
├── .gitignore
└── README.md  
```
## Dashboard
