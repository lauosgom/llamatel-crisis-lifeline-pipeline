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
