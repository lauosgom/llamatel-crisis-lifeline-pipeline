# data-engineering-zoomcamp-final-project
Repository to host the final project of the Data Engineering Zoomcamp
## Problem Statement

Dataset

The Telefono de la Esperanza (Phone of Hope) is a non-governmental organization that cares about mental health. One of their main services is a helpline where people can call for psychological help or just to be heard. All calls are answered by an expert who listens, offers advice and next steps. After every call, the expert, or "orientador," fills out a form cataloging the type of call and problem and providing a short summary of the call.

Currently, they are trying to transition to better software and data infrastructure. However, in order to preserve the old data on their servers, they must download it manually and each call produces a single pdf. This process is time-consuming because it requires downloading each call individually since 20xx. To facilitate this process, I designed a web scraper that logs in to the website with the proper credentials and downloads the data in PDF format. The data is stored in a data lake, a Google Cloud Storage bucket. Then, the data is processed by extracting the call information and building a table. Finally, the data is merged into a table in BigQuery.

The table goes through a series of transformation following business rules provided by members of the organization


then I created a dashboard where we can see some of the basic statistics for the data.

The cadence is every xx

## Data Pipeline
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
## Technologies

1. Create service account and save keys
2. Terraform create bucket and bigquery dataset
3. Kestra: upload data to bigquery table
4. dbt
5. 

## Project structure

my-project/  
│  
├── terraform/                        # Cloud infrastructure  
│   ├── main.tf  
│   ├── variables.tf  
│   ├── outputs.tf  
│   └── modules/  
│       ├── gcs/                      # GCS data lake bucket  
│       └── bigquery/                 # BQ datasets & tables  
│  
├── ingestion/                        # Steps 1–3: download, extract, upload  
│   ├── scraper.py                    # (1) Download PDFs from webpage  
│   ├── extractor.py                  # (2) Extract data from PDFs → DataFrame  
│   └── uploader.py                   # (3) Upload PDFs to GCS  
│
├── warehouse/                        # Step 4: BigQuery loading  
│   └── loader.py                     # Merge DataFrame into BQ table  
│  
├── transform/                        # Step 5: dbt transformations  
│   ├── dbt_project.yml  
│   ├── profiles.yml  
│   ├── models/  
│   │   ├── staging/                  # Raw → cleaned models  
│   │   └── marts/                    # End table(s) for dashboard  
│   └── tests/  
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
├── config/                           # Shared config & secrets references  
│   └── settings.py                   # Env vars, GCS bucket names, BQ IDs, etc.  
│  
├── tests/                            # Unit & integration tests  
│   ├── test_scraper.py  
│   ├── test_extractor.py  
│   └── test_loader.py  
│  
├── .env.example                      # Template for required env vars  
├── requirements.txt  
├── Dockerfile                        # Optional: containerized Prefect worker  
└── README.md  

## Dashboard
