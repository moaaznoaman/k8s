from flask import Flask , request, render_template, jsonify, json
from forms import SignUpForm
from collections import defaultdict
from db_conn import db
import requests
import socket
import os
import json

SECRET_KEY = os.urandom(32)
versionSVC = os.environ['VERSION_SERVICE']
env = os.environ['APP_ENVIRONMENT']
versionURL = 'http://{}:8080/version'.format(versionSVC)
app = Flask(__name__,template_folder='templetes/')
app.config['JSON_SORT_KEYS'] = False
app.config['SECRET_KEY'] = SECRET_KEY
version="V1"
status=""

@app.route("/")
def home():
    return "Hello, World from {}".format(socket.gethostname())

@app.route("/welcome")
def welcome():
    return "Hello, World from {}".format(socket.gethostname())

@app.route('/api/version')
def version():
    version = "V1"
    appname = "employees"
    status = "up"
    hostname = socket.gethostname()

    return jsonify(
        hostname=hostname,
        app=appname,
        version=version,
        status=status
    )
@app.route('/api/info')
def info():
    version = "V1"
    appname = "employees"
    hostname = socket.gethostname()
    
    return jsonify(
        hostname=hostname,
        app=appname,
        version=version,
        env=env
    )
    
@app.route('/api/health')
def health():
    healthStatus = defaultdict(dict)
    healthURL='http://{}:8080/health'.format(versionSVC)
    healthResponse = requests.get(url=healthURL)
    print(healthResponse)
    healthCheck = json.loads(healthResponse.text)
    version = "V1"
    appname = "employees"
    status = "up"
    healthStatus['employees']['appname'] = "employees"
    healthStatus['employees']['version'] = "V1"
    healthStatus['employees']['status'] = "up"
    healthStatus['version']['appname'] = "version"
    healthStatus['version']['version'] = healthCheck['version']
    healthStatus['version']['status'] = healthCheck['status']
    return jsonify(healthStatus)

@app.route('/api/hostname')
def hostname():
    return "{} from {}".format(socket.gethostname(), request.remote_addr)

@app.route('/api/details/<name>', methods=['GET'])
def details(name):
    data = {}
    response = requests.get(url=versionURL)
    print(response)
    version = response.text
    query = '''
        select s.first_name,s.last_name,s.department,s.email,s.comment from app.employees s where s.first_name ="''' + name + '"'
    # print(query)
    with db() as conn:
        conn.execute(query)
        data = [dict(firstname=row[0], lastname=row[1],department=row[2],email=row[3],comment=row[4]) for row in conn.fetchall()]
    print(data)
    if len(data) == 0:
        return render_template('unavailable_user.html', user=name,version=version)
    else:
        return render_template('details.html', data=data,version=version)

@app.route('/api/register', methods=['GET','POST'])
def register():
    form = SignUpForm()
    if form.is_submitted():
        details = request.form
        print(details)
        firstname = details['firstname']
        lastname = details['lastname']
        department = details['department']
        email = details['email']
        query = """insert into app.employees (first_name,last_name,department,email,comment) values ('{}','{}','{}','{}','{}')""".format(firstname,lastname,department,email,comment)
        with db() as conn:
            conn.execute(query)
        return render_template('preview.html',firstname=firstname,lastname=lastname,department=department,email=email,comment=comment)
    return render_template('register_form.html',form=form,version=version)

"""
curl -X POST -H "Content-Type: application/json" -d '{
  "firstname": "mizoo",
  "lastname": "noaman",
  "department": "ITT",
  "email": "mizoo.refat@hotmial.com"
}' http://10.0.0.200/register
"""