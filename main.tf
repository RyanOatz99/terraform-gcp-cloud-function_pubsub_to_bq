resource "random_string" "random" {
  length  = 16
  special = false
}

data "archive_file" "dotfiles" {
  type        = "zip"
  output_path = "${path.module}/dotfiles.zip"

  source {
    content  = file("${path.module}/code/requirements.txt")
    filename = "requirements.txt"
  }

  source {
    content  = file("${path.module}/code/main.py")
    filename = "main.py"
  }
}

resource "google_storage_bucket" "bucket" {
  name = "pubsub_to_bq_${lower(random_string.random.result)}_deployment_bucket"

  force_destroy = true
  location      = "EUROPE-WEST3"
}

resource "google_storage_bucket_object" "archive" {
  name   = "dotfiles.zip"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.dotfiles.output_path
}

resource "google_cloudfunctions_function" "function" {
  name        = "pubsub_to_bq_${lower(random_string.random.result)}"
  description = "Pubsub topic subscriber to sent messages directly to BigQuery"
  runtime     = "python39"
  region      = var.region

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  entry_point           = "consume"
  service_account_email = google_service_account.sa.email

  environment_variables = {
    TABLE_ID = var.bigquery_table
  }

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = var.topic_name
  }

  depends_on = [google_storage_bucket_object.archive]
}