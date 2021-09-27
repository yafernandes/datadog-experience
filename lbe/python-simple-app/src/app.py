# https://ddtrace.readthedocs.io/en/stable/integrations.html#flask
import logging
import os
import sys

import json_log_formatter

from flask import Flask

root = logging.getLogger()
json_handler = logging.StreamHandler(sys.stdout)
json_handler.setFormatter(json_log_formatter.JSONFormatter())

root.handlers.clear()
root.addHandler(json_handler)

logger = logging.getLogger('lbe')
logger.setLevel(logging.INFO)

app = Flask(__name__)

@app.route('/hello_world')
def hello_world():
    logger.info(f'Waking up...')
    return 'Hello world!', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
