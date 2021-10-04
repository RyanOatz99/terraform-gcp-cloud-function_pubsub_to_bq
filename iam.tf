resource "google_service_account" "sa" {
  account_id = "pubsubtobq-${lower(random_string.random.result)}"
}

resource "google_pubsub_topic_iam_member" "sa_subscriber" {
  topic  = var.topic_name
  role   = "roles/pubsub.subscriber"
  member = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "sa_bigquery" {
  role   = "roles/bigquery.dataEditor"
  member = "serviceAccount:${google_service_account.sa.email}"
}
