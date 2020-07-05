import os
from app import app

# from library.prometheus_flask import app
# from library.html_template_index import app

if __name__ == '__main__':
    app.debug = True
    host = os.environ.get('IP', '0.0.0.0')
    # print(host)
    port = int(os.environ.get('PORT', 8080))
    app.run(host=host, port=port)