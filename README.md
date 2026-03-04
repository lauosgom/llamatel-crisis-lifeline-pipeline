# data-engineering-zoomcamp-final-project
Repository to host the final project of the Data Engineering Zoomcamp
## Problem Statement

Dataset

Telefono de la esperanza is a NGO that cares about mental health. One of their main products is a help line, where people reach out to seek for psicological help. All calls are answer by an expert that listens, catalogs the type of call and problen, provides resources that might help the person and performs a short summary in the platform.

Currently, they are trying to move to a better infrastructure, but in order to preserve the old data in their servers, they need to download it manually, which takes a long time given that you have to download call by call since 20xx. For this, I designed a web scapper that goes to the web page, logs in with the proper credentials and downloads the data in pdf. This data is stored in a data lake gcs, then the data is processed by extracting the call information using regex. Finally, the data is merged to a table in bigquery. then I created a dashboard where we can see some of the basic statistics for the data.

The cadence is every xx

## Data Pipeline
the data is stored in pdf files hosted in a google drive folder
script of extraction using some regex
merge tables into bigquery
dashboard
- have a 'flow' in kestra to do this every month

## Technologies

1. Create service account and save keys
2. Terraform create bucket and bigquery dataset
3. Kestra: upload data to bigquery table
4. dbt
5. 

## Dashboard
