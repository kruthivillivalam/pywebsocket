FROM python:3.6

# uwsgi
ENV UWSGI_DIR "/etc/uwsgi"

# ssh
ENV SSH_PASSWD "root:Docker!"

# BOKEH Server
ENV BOKEH_HOST "localhost"

# =======
# Install
# =======

RUN set -ex \
        && apt-get update \
        && apt-get -y install apt-transport-https \
        # Fix Locale problem with Python/Bokeh/ODBC connections
        && apt-get -y install locales \
        && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
        && locale-gen

RUN set -ex \
        # Upgrade pip
        && pip install --upgrade pip \
        # nginx
        && apt-get install -y -V --no-install-recommends nginx \
        # Install Supervisord
        && apt-get install -y supervisor \
        # ssh
        && apt-get install -y --no-install-recommends openssh-server \
        && rm -r /var/lib/apt/lists/* \
        # uwsgi
        && pip install uwsgi \
        #
        && test ! -d $UWSGI_DIR && mkdir -p $UWSGI_DIR

RUN echo "$SSH_PASSWD" | chpasswd

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
        
# =========
# Configure
# =========

# ssh
COPY sshd_config /etc/ssh/

# Custom Supervisord config
COPY /supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN set -ex \
        # Make NGINX run on the foreground
        && echo "daemon off;" >> /etc/nginx/nginx.conf \
        # Remove default configuration from Nginx
        && rm /etc/nginx/sites-enabled/default

# Copy the modified Nginx conf
COPY /nginx.conf /etc/nginx/conf.d/nginx.conf
#COPY /nginx.conf /etc/nginx/sites-enabled/default

# Copy the base uWSGI ini file to enable default dynamic uwsgi process number
COPY /uwsgi.ini /etc/uwsgi/

# Which uWSGI .ini file should be used, to make it customizable
ENV UWSGI_INI /app/uwsgi.ini

# By default, allow unlimited file sizes, modify it to limit the file sizes
# To have a maximum of 1 MB (Nginx's default) change the line to:
# ENV NGINX_MAX_UPLOAD 1m
ENV NGINX_MAX_UPLOAD 0

# URL under which static (not modified by Python) files will be requested
# They will be served by Nginx directly, without being handled by uWSGI
ENV STATIC_URL /static
# Absolute path in where the static files wil be
ENV STATIC_PATH /app/static

# If STATIC_INDEX is 1, serve / with /static/index.html directly (or the static URL configured)
# ENV STATIC_INDEX 1
ENV STATIC_INDEX 0

EXPOSE 80 2222 

# Copy the entrypoint that will generate Nginx additional configs
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# Set the BOKEH_HOST to the hostname of the Web App you plan to use
ENV BOKEH_HOST="*"
# App
RUN mkdir /app
WORKDIR /app
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY ./app /app

# Bokeh Server
COPY bokeh_server.sh /bokeh_server.sh
RUN chmod +x /bokeh_server.sh

CMD ["/usr/bin/supervisord"]
