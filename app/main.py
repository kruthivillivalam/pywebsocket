from flask import Flask, render_template
from flask_bootstrap import Bootstrap

import numpy as np

from bokeh.plotting import figure
from bokeh.layouts import column
from bokeh.models import ColumnDataSource, Slider
from bokeh.embed import components
from bokeh.embed import server_document

from os import environ

app = Flask(__name__)

# Enable bootstrap in flask
bootstrap = Bootstrap(app)

# Absolute path to the Bokeh URL
bokeh_root = "/bokeh"
bokeh_use_relative = True

def get_bokeh_url(path):
    return "{}{}".format(bokeh_root, path)

def gen_main_page():
    env_list = ""
    for key in environ:
        env_list += "{} : {}<br>".format(key, environ[key])

    return "<h1>Flask Web Server</h1><h2>Environment List</h2><p>{}</p>".format(env_list)


@app.route("/", methods=["GET"])
def main_app_page():
    script = gen_main_page()
    return render_template("embed_graph.html", script=script)


@app.route("/sin", methods=["GET"])
def sin():
    script = server_document(url=get_bokeh_url("/sine"), relative_urls=bokeh_use_relative)
    return render_template("embed_graph.html", script=script)


@app.route("/cos", methods=["GET"])
def cos():
    script = server_document(url=get_bokeh_url("/cosine"), relative_urls=bokeh_use_relative)
    return render_template("embed_graph.html", script=script)


"""
If we run the file directly, then run the flask internal web server to serve up files.

To manually serve the Bokeh Server graphs, run the Bokeh Serve command from the app
folder:

bokeh serve --port 5006 --allow-websocket-origin=localhost:5000 bokeh/*.py

"""
if __name__ == '__main__':
    # Set our parameters to values that will work locally
    bokeh_root = "http://localhost:5006"
    bokeh_use_relative = False

    app.run(host='localhost', port=5000)
