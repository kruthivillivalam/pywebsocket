import numpy as np

from bokeh.plotting import figure, curdoc
from bokeh.layouts import column
from bokeh.models import ColumnDataSource, Slider
from bokeh.embed import components


#from bokeh.application import Application
#from bokeh.application.handlers import FunctionHandler
#from bokeh.embed import autoload_server
#from bokeh.server.server import Server

def sine_chart(doc):
    x = np.linspace(1, 10, 1000)
    y = np.log(x) * np.sin(x)

    source = ColumnDataSource(data=dict(x=x, y=y))

    plot = figure(plot_width=650, plot_height=300)
    plot.line('x', 'y', source=source)

    slider = Slider(start=1, end=10, value=1, step=0.1)

    def callback(attr, old, new):
        y = np.log(x) * np.sin(x*new)
        source.data = dict(x=x, y=y)

    slider.on_change('value', callback)

    doc.add_root(column(slider, plot))


def sine_static():
    x = np.linspace(1, 10, 1000)
    y = np.log(x) * np.sin(x)

    source = ColumnDataSource(data=dict(x=x, y=y))

    plot = figure(plot_width=650, plot_height=300)
    plot.line('x', 'y', source=source)

    return components(plot)

sine_chart(curdoc())

