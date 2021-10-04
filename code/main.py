import logging
import base64
import os
import json

from google.cloud import bigquery


def consume(event, _):
    table_id = os.getenv("TABLE_ID")

    if table_id is None:
        logging.error("TABLE_ID is missing")
        return

    if 'data' in event:
        event_data = json.loads(base64.b64decode(event['data']).decode('utf-8'))
        client = bigquery.Client()
        errors = client.insert_rows_json(table_id, [event_data])
        if not errors:
            logging.info("New rows have been added.")
        else:
            logging.error("Encountered errors while inserting row: {}".format(errors))
    else:
        logging.info("Message did not contain data key")
