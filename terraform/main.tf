terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.20.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

resource "google_storage_bucket" "calls-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true
  storage_class = var.gs_storage_class

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "raw" {
  dataset_id                 = "raw"
  location                   = var.location
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "staging" {
  dataset_id                 = "staging"
  location                   = var.location
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "intermediate" {
  dataset_id                 = "intermediate"
  location                   = var.location
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "seeds" {
  dataset_id                 = "seeds"
  location                   = var.location
  delete_contents_on_destroy = true
}

resource "google_bigquery_dataset" "marts" {
  dataset_id                 = "marts"
  location                   = var.location
  delete_contents_on_destroy = true
}

resource "google_bigquery_table" "table-test-yellow" {
  dataset_id          = "raw"
  table_id            = "llamatel-llamadas"
  deletion_protection = false
  depends_on          = [google_bigquery_dataset.raw]

  time_partitioning {
    type  = "DAY"
    field = "llamada_fecha"
  }

  schema = <<EOF
[
  {
    "name": "num_pages",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Number of pages in the PDF."
  },
  {
    "name": "medio_contacto",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "How the contact was made it can be by telephone, in person, email, etc."
  },
  {
    "name": "codigo_numero",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Number of the ID of the contact."
  },
  {
    "name": "codigo_letras",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The letters of the ID of the contact."
  },
  {
    "name": "total_llamadas",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Total number of calls."
  },
  {
    "name": "llamante_sexo",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The sex of the caller. 1= Male 2= Female 0= Unknown"
  },
  {
    "name": "llamante_edad",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The age of the caller."
  },
  {
    "name": "llamante_estado_civil",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The marital status of the caller."
  },
  {
    "name": "llamante_convive",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Whether the caller lives with someone."
  },
  {
    "name": "llamante_asiduidad",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The frequency of calls made by the caller."
  },
  {
    "name": "llamante_problema",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The problem reported by the caller."
  },
  {
    "name": "llamante_naturaleza",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The nature of the problem reported by the caller."
  },
  {
    "name": "llamante_inicio",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "When the problem started."
  },
  {
    "name": "llamante_actitud_orientador",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The attitude of the caller according to the counselor."
  },
  {
    "name": "llamante_presentacion",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "How the caller presents the problem."
  },
  {
    "name": "llamante_paralenguaje",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The paralanguage of the caller."
  },
  {
    "name": "llamante_procedencia",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The origin of the caller."
  },
  {
    "name": "llamante_peticion",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The request of the caller."
  },
  {
    "name": "llamante_actitud_problema",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The attitude of the caller towards the problem."
  },
  {
    "name": "llamante_llamada_derivada",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Whether the call was forwarded to another counselor."
  },
  {
    "name": "tercero_sexo",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The sex of the third party."
  },
  {
    "name": "tercero_edad",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The age of the third party."
  },
  {
    "name": "tercero_estado_civil",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The marital status of the third party."
  },
  {
    "name": "tercero_convive",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Whether the third party lives with someone."
  },
  {
    "name": "tercero_relacion",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The relation of the third party to the caller."
  },
  {
    "name": "tercero_problema",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The problem reported by the third party."
  },
  {
    "name": "tercero_actitud_problema",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The attitude of the third party towards the problem."
  },
  {
    "name": "llamada_hora",
    "type": "TIME",
    "mode": "NULLABLE",
    "description": "The hour of the call."
  },
  {
    "name": "llamada_fecha",
    "type": "DATE",
    "mode": "NULLABLE",
    "description": "The date of the call."
  },
  {
    "name": "llamada_resultado",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The result of the call."
  },
  {
    "name": "llamada_duracion",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "The duration of the call in minutes."
  },
  {
    "name": "entrevista_clave",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Code of the interview."
  },
  {
    "name": "entrevista_referencia",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Reference of the interview."
  },
  {
    "name": "entrevista_hora",
    "type": "TIME",
    "mode": "NULLABLE",
    "description": "Time of the interview."
  },
  {
    "name": "entrevista_fecha",
    "type": "DATE",
    "mode": "NULLABLE",
    "description": "Date of the interview."
  },
  {
    "name": "orientador_clave_letras",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Code of the counselor letters."
  },
  {
    "name": "orientador_clave_numero",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Code of the counselor number."
  },
  {
    "name": "orientador_nivel_ayuda",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Level of help provided by the counselor."
  },
  {
    "name": "orientador_sentimientos",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Sentiments of the counselor."
  },
  {
    "name": "orientador_autoevaluacion",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Self-evaluation of the counselor."
  },
  {
    "name": "orientador_actitudes_equivocadas",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Incorrect attitudes of the counselor."
  },
  {
    "name": "orientador_satisfaccion_llamante",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Satisfaction of the caller with the counselor."
  },
  {
    "name": "sintesis",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Summary of the call intervention."
  },
  {
    "name": "filename",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Source PDF filename."
  },
  {
    "name": "imported_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "Datetime when the record was imported."
  },
  {
    "name": "gcs_path",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "GCS path of the source PDF."
  }
]
EOF
}

# --- Compute Engine VM for Prefect worker ---

resource "google_compute_instance" "prefect-worker" {
  name         = "prefect-worker"
  machine_type = "e2-micro"
  zone         = "${var.region}-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {} # gives the VM a public IP
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3-pip python3-venv git

    # install uv
    curl -Lsf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"

    # swap file for Chromium memory headroom
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
  EOF

  tags = ["prefect-worker"]
}

resource "google_compute_firewall" "prefect-worker-ssh" {
  name    = "allow-ssh-prefect-worker"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["prefect-worker"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "prefect-server" {
  name    = "allow-prefect-server"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["4200"]
  }

  target_tags   = ["prefect-worker"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_bigquery_table" "table-firebase" {
  dataset_id          = "raw"
  table_id            = "llamatel_llamadas_firebase"
  deletion_protection = false
  depends_on          = [google_bigquery_dataset.raw]

  schema = jsonencode([
    # 1. General Call Metadata
    { name = "L_ID_Llamada",               type = "STRING",    mode = "NULLABLE" },
    { name = "L_Orientador",               type = "STRING",    mode = "NULLABLE" },
    { name = "L_Codigo_Orientador",        type = "STRING",    mode = "NULLABLE" },
    { name = "OrientadorUid",              type = "STRING",    mode = "NULLABLE" },
    { name = "L_Fecha",                    type = "STRING",    mode = "NULLABLE" },
    { name = "L_Hora",                     type = "STRING",    mode = "NULLABLE" },
    { name = "L_Medio_Contacto",           type = "STRING",    mode = "NULLABLE" },
    { name = "L_Como_Conoce",             type = "STRING",    mode = "NULLABLE" },
    { name = "CreatedAt",                  type = "TIMESTAMP", mode = "NULLABLE" },

    # 2. User Data (Llamante)
    { name = "U_Sexo",                     type = "STRING",    mode = "NULLABLE" },
    { name = "U_Edad",                     type = "STRING",    mode = "NULLABLE" },
    { name = "U_Estado_Civil",             type = "STRING",    mode = "NULLABLE" },
    { name = "U_Convive",                  type = "STRING",    mode = "NULLABLE" },
    { name = "U_Asiduidad",                type = "STRING",    mode = "NULLABLE" },
    { name = "U_Naturaleza",               type = "STRING",    mode = "NULLABLE" },
    { name = "U_Inicio",                   type = "STRING",    mode = "NULLABLE" },
    { name = "U_Actitud_Orientador",       type = "STRING",    mode = "NULLABLE" },
    { name = "U_Presentacion",             type = "STRING",    mode = "NULLABLE" },
    { name = "U_Paralenguaje",             type = "STRING",    mode = "NULLABLE" },
    { name = "U_Procedencia",              type = "STRING",    mode = "NULLABLE" },
    { name = "U_Peticion",                 type = "STRING",    mode = "NULLABLE" },
    { name = "U_Actitud_Problema_1",       type = "STRING",    mode = "NULLABLE" },
    { name = "U_Actitud_Problema_2",       type = "STRING",    mode = "NULLABLE" },
    { name = "U_Cond_Socioeconomica",      type = "STRING",    mode = "NULLABLE" },

    # 3. User Problems
    { name = "U_Problematica_1",           type = "STRING",    mode = "NULLABLE" },
    { name = "U_Problema_1",               type = "STRING",    mode = "NULLABLE" },
    { name = "U_Problematica_2",           type = "STRING",    mode = "NULLABLE" },
    { name = "U_Problema_2",               type = "STRING",    mode = "NULLABLE" },
    { name = "U_Problematica_3",           type = "STRING",    mode = "NULLABLE" },
    { name = "U_Problema_3",               type = "STRING",    mode = "NULLABLE" },

    # 4. Third-Party Data (Tercero)
    { name = "T_Sexo_Tercero",             type = "STRING",    mode = "NULLABLE" },
    { name = "T_Edad_Tercero",             type = "STRING",    mode = "NULLABLE" },
    { name = "T_Estado_Civil_Tercero",     type = "STRING",    mode = "NULLABLE" },
    { name = "T_Convive",                  type = "STRING",    mode = "NULLABLE" },
    { name = "T_Relacion",                 type = "STRING",    mode = "NULLABLE" },
    { name = "T_Problematica_1",           type = "STRING",    mode = "NULLABLE" },
    { name = "T_Problema_1",               type = "STRING",    mode = "NULLABLE" },
    { name = "T_Problematica_2",           type = "STRING",    mode = "NULLABLE" },
    { name = "T_Problema_2",               type = "STRING",    mode = "NULLABLE" },
    { name = "T_Problematica_3",           type = "STRING",    mode = "NULLABLE" },
    { name = "T_Problema_3",               type = "STRING",    mode = "NULLABLE" },
    { name = "T_Actitud_Problema_1",       type = "STRING",    mode = "NULLABLE" },
    { name = "T_Actitud_Problema_2",       type = "STRING",    mode = "NULLABLE" },

    # 5. Related Person (Relacionado)
    { name = "R_Sexo_Relacionado",         type = "STRING",    mode = "NULLABLE" },
    { name = "R_Edad_Relacionado",         type = "STRING",    mode = "NULLABLE" },
    { name = "R_Estado_Civil_Relacionado", type = "STRING",    mode = "NULLABLE" },
    { name = "R_Convive",                  type = "STRING",    mode = "NULLABLE" },
    { name = "R_Relacion",                 type = "STRING",    mode = "NULLABLE" },
    { name = "R_Problematica_1",           type = "STRING",    mode = "NULLABLE" },
    { name = "R_Problema_1",               type = "STRING",    mode = "NULLABLE" },
    { name = "R_Problematica_2",           type = "STRING",    mode = "NULLABLE" },
    { name = "R_Problema_2",               type = "STRING",    mode = "NULLABLE" },
    { name = "R_Problematica_3",           type = "STRING",    mode = "NULLABLE" },
    { name = "R_Problema_3",               type = "STRING",    mode = "NULLABLE" },

    # 6. Call Outcome & Advisor Evaluation
    { name = "L_Llamada_Derivada",         type = "STRING",    mode = "NULLABLE" },
    { name = "L_Resultado",                type = "STRING",    mode = "NULLABLE" },
    { name = "L_Duracion",                 type = "STRING",    mode = "NULLABLE" },
    { name = "O_Clave",                    type = "STRING",    mode = "NULLABLE" },
    { name = "O_Autoevaluacion",           type = "STRING",    mode = "NULLABLE" },
    { name = "O_Volvera_Llamar",           type = "STRING",    mode = "NULLABLE" },
    { name = "O_Nivel_Ayuda_1",            type = "STRING",    mode = "NULLABLE" },
    { name = "O_Nivel_Ayuda_2",            type = "STRING",    mode = "NULLABLE" },
    { name = "O_Sentimientos_1",           type = "STRING",    mode = "NULLABLE" },
    { name = "O_Sentimientos_2",           type = "STRING",    mode = "NULLABLE" },
    { name = "O_Sentimientos_3",           type = "STRING",    mode = "NULLABLE" },
    { name = "O_Actitud_Equivocada_1",     type = "STRING",    mode = "NULLABLE" },
    { name = "O_Actitud_Equivocada_2",     type = "STRING",    mode = "NULLABLE" },
    { name = "O_Satisfaccion_1",           type = "STRING",    mode = "NULLABLE" },
    { name = "O_Satisfaccion_2",           type = "STRING",    mode = "NULLABLE" },
    { name = "L_Sintesis",                 type = "STRING",    mode = "NULLABLE" },

    # Row metadata
    { name = "document_id",               type = "STRING",    mode = "NULLABLE" },
    { name = "last_updated",              type = "TIMESTAMP", mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "table-firebase-changelog" {
  project             = "singular-arbor-401018"
  dataset_id          = "raw"
  table_id            = "llamatel_llamadas_firebase_raw_changelog"
  deletion_protection = false
  depends_on          = [google_bigquery_dataset.raw]

  schema = jsonencode([
    { name = "timestamp", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "event_id", type = "STRING", mode = "NULLABLE" },
    { name = "document_name", type = "STRING", mode = "NULLABLE" },
    { name = "operation", type = "STRING", mode = "NULLABLE" },
    { name = "data", type = "STRING", mode = "NULLABLE" },
    { name = "old_data", type = "STRING", mode = "NULLABLE" },
    { name = "document_id", type = "STRING", mode = "NULLABLE" }
  ])
}

resource "google_bigquery_table" "table-lists-firebase" {
  project             = "singular-arbor-401018"
  dataset_id          = "raw"
  table_id            = "llamatel_lists_firebase"
  deletion_protection = false
  depends_on          = [google_bigquery_dataset.raw]

  schema = jsonencode([
    { name = "lista", type = "STRING", mode = "NULLABLE" },
    { name = "active", type = "BOOLEAN", mode = "NULLABLE" },
    { name = "label", type = "STRING", mode = "NULLABLE" },
    { name = "value", type = "STRING", mode = "NULLABLE" },
    { name = "document_id", type = "STRING", mode = "NULLABLE" },
    { name = "last_updated", type = "TIMESTAMP", mode = "NULLABLE" }
  ])
}

resource "google_bigquery_table" "table-lists-changelog" {
  project             = "singular-arbor-401018"
  dataset_id          = "raw"
  table_id            = "llamatel_lists_firebase_raw_changelog"
  deletion_protection = false
  depends_on          = [google_bigquery_dataset.raw]

  schema = jsonencode([
    { name = "timestamp", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "event_id", type = "STRING", mode = "NULLABLE" },
    { name = "document_name", type = "STRING", mode = "NULLABLE" },
    { name = "operation", type = "STRING", mode = "NULLABLE" },
    { name = "data", type = "STRING", mode = "NULLABLE" },
    { name = "old_data", type = "STRING", mode = "NULLABLE" },
    { name = "document_id", type = "STRING", mode = "NULLABLE" }
  ])
}

resource "google_bigquery_table_iam_binding" "lists-changelog-iam" {
  project    = "singular-arbor-401018"
  dataset_id = "raw"
  table_id   = "llamatel_lists_firebase_raw_changelog"
  role       = "roles/bigquery.dataOwner"
  members    = [
    "serviceAccount:ext-firestore-bigquery-export@telespantgrav.iam.gserviceaccount.com"
  ]
  depends_on = [google_bigquery_table.table-lists-changelog]
}
