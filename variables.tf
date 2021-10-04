variable "topic_name" {
  description = "Topic name to consume messages from"
}

variable "bigquery_table" {
  type        = string
  description = "table_id of target table"
}

variable "region" {
  type        = string
  description = "Region to deploy dataflow job to"
}
