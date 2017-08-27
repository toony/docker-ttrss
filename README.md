# docker-ttrss

This [Docker](https://www.docker.com) image allows you to run the [Tiny Tiny RSS](http://tt-rss.org) feed reader.
Keep your feed history to yourself and access your RSS and atom feeds from everywhere.
You can access it through an easy to use webinterface on your desktop, your mobile browser
or using one of the available apps.

## Quickstart

This section assumes you want to get started quickly, using mysql database.
The following sections explain the steps in more detail. So let's start.

Just start up a new database container:

```bash
$ docker run --name ttrss-mysql \
    -e MYSQL_ROOT_PASSWORD=mysqlRootPasswd \
    -e MYSQL_DATABASE=ttrss \
    -e MYSQL_USER=ttrss \
    -e MYSQL_PASSWORD=ttrssDbPasswd \
    -d mysql:5
```

Run Tiny tiny RSS container:

```bash
$ docker run --name ${TTRSS_CONTAINER_NAME} \
    -e DB_HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ttrss-mysql) \
    -e DB_PORT="3306" \
    -e DB_NAME=ttrss \
    -e DB_USER=ttrss \
    -e DB_PASS=ttrssDbPasswd \
    -e DB_ENV_USER=root \
    -e DB_ENV_PASS=mysqlRootPasswd \
    -e SELF_URL_PATH="http://localhost/" \
    -p 80:80 \
    -d toony/ttrss
```

Running this command for the first time will download the image automatically.

## Accessing your webinterface

The above example exposes the Tiny Tiny RSS webinterface on port 80, so that you can browse to:

http://localhost/

The default login credentials are:

* Username: admin
* Password: password

Obviously, you're recommended to change these as soon as possible.

## Installation Walkthrough

Having trouble getting the above to run?
This is the detailed installation walkthrough.
If you've already followed the [quickstart](#quickstart) guide and everything works, you can skip this part.

### Select database

This container requires MySQL database instance.

Following docker's best practices, this container does not contain its own database,
but instead expects you to supply a running instance.
While slightly more complicated at first, this gives your more freedom as to which
database instance and configuration you're relying on.
Also, this makes this container quite disposable, as it doesn't store any sensitive
information at all.

### SELF_URL_PATH

The `SELF_URL_PATH` config value should be set to the URL where this TinyTinyRSS
will be accessible at. Setting it correctly will enable PUSH support and make
the browser integration work. Default value: `http://localhost`.

For more information check out the [official documentation](https://github.com/gothfox/Tiny-Tiny-RSS/blob/master/config.php-dist#L22).

## Advanced configurations

### Enable HTTPs

Put a NGinx reverse proxy in front of Tiny Tiny RSS container to enable SSL support using something like:

```
server {
  listen 443;
  server_name localhost;

  ssl on;
  ssl_certificate  /path/to/ssl/certs.pem;
  ssl_certificate_key  /path/to/ssl/privateKey.pem;
  
  location / {
    proxy_pass http://127.0.0.1/;
    proxy_set_header X-FORWARDED-PROTO https;
  }
}
```

_X-FORWARDED-PROTO_ header is needed to pass Tiny Tiny RSS URL sanity checks.

You can access to Tiny Tiny RSS using: `https://localhost/`

### Tiny Tiny RSS in a subfolder

To access Tiny Tiny RSS using URL like _http://example.org/ttrss/_, you need 
to start your Tiny Tiny RSS container using docker option:

```
-e SELF_URL_PATH=http://example.org/ttrss/
```

### Tiny Tiny RSS in a subfolder and HTTPs

To access Tiny Tiny RSS using URL like _https://example.org/ttrss/_, you need 
to start your Tiny Tiny RSS container using docker option:

```
-e SELF_URL_PATH=https://example.org/ttrss/
```

Put a NGinx reverse proxy in front of Tiny Tiny RSS container to enable SSL support using something like:

```
server {
  listen 443;
  server_name example.org;

  ssl on;
  ssl_certificate  /path/to/ssl/certs.pem;
  ssl_certificate_key  /path/to/ssl/privateKey.pem;
  
  location /ttrss {
    proxy_pass http://127.0.0.1/;
    proxy_set_header Host example.org;
    proxy_set_header X-FORWARDED-PROTO https;
  }
}
```

_Host_ and _X-FORWARDED-PROTO_ header are needed to pass Tiny Tiny RSS URL sanity checks.

You can access to Tiny Tiny RSS using: `https://example.org/ttrss/`
