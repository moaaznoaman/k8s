from flask import Flask , json, request, render_template, jsonify
from db_conn import db
import requests
import socket
import os
import json

app = Flask(__name__,template_folder='templetes/')
app.config['JSON_SORT_KEYS'] = False

version="V2"
hostname=socket.gethostname()

@app.route("/version")
def home():
    return "V2"

@app.route("/health")
def health():
    status = ""
    query = '''select avail from version.version where version="v2";'''
    # print(query)
    with db() as conn:
        conn.execute(query)
        data = conn.fetchall()
        for i in data:
            status = i[0]
    return jsonify(
        hostname=hostname,
        version=version,
        status=status
    )