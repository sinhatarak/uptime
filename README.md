# watchmen: a service monitor for node.js

[![Build Status](https://secure.travis-ci.org/iloire/watchmen.png?branch=master)](http://travis-ci.org/iloire/watchmen)

- [What is watchmen?](#what-is-watchmen)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Running and stopping watchmen](#running-and-stopping-watchmen)
- [Development workflow](#development-workflow)
- [Managing your node processes with pm2](#managing-your-node-processes-with-pm2)
- [Managing processes with node-foreman](#managing-processes-with-node-foreman)
- [Configuration](#configuration)
- [Ping services](#ping-services)
- [Monitor plugins](#monitor-plugins)
- [Storage providers](#storage-providers)
- [Using fake data for development](#using-fake-data-for-development)
- [Running with docker](#running-with-docker)
- [Terraform scripts for digital-ocean](#terraform-scripts-for-digital-ocean)
- [Tests](#tests)
- [Debugging](#debugging)
- [Contributing](#contributing)
- [Style guide](#style-guide)
- [History](#history)
- [Donations](#donations)
- [License](#license)

## What is watchmen?

- watchmen monitors health (outages, uptime, response time warnings, avg. response time, etc) for your servers.
- **ping types are pluggable** through npm modules. At this time, `http-head` and `http-contains` are available. Read more about ping services and how to create one below.
- watchmen provides **custom actions through plugins** (console outpug, email notifications, etc).
- the code base aims to be simple and easy to understand and modify.

## Screenshots

![watchmen, service details](https://github.com/iloire/watchmen/raw/master/screenshots/watchmen-details-mobile-01.png)

![watchmen, service list](https://github.com/iloire/watchmen/raw/master/screenshots/watchmen-list-mobile-01.png)

![watchmen, add service](https://github.com/iloire/watchmen/raw/master/screenshots/watchmen-add.png)

![watchmen, list services](https://github.com/iloire/watchmen/raw/master/screenshots/watchmen-list-wide-01.png)


## Installation

### Requirements

Get redis from [redis.io](http://redis.io/download) and install it.

### Installing watchmen

Clone the repo by using

    $ git clone git@github.com:iloire/watchmen.git

or

    $ git clone https://github.com/iloire/watchmen.git

Then install the required dependencies using ``npm``

    $ cd watchmen
    $ npm install

## Running and stopping watchmen

Make sure you have `redis-server` in your `PATH`. Then you can run watchmen services:

    $ redis-server redis.conf
    $ node run-monitor-server.js
    $ node run-web-server.js

## Development workflow

### Fetching bower dependencies and building static assets

    $ npm run build

### Dev build watch

    $ npm run build:watch

### Running tests

See below.

## Managing your node processes with pm2

Install pm2:

    $ npm install -g pm2

Configure env variables:

    $ export WATCHMEN_WEB_PORT=8080

Run servers:

    $ pm2 start run-monitor-server.js
    $ pm2 start run-web-server.js

Server list:

    $ pm2 list

![List of pm2 services](https://github.com/iloire/watchmen/raw/master/screenshots/pm2-01.png)

## Managing processes with node-foreman

`node-foreman` can be used to run the monitor and web server as an Upstart
service. On Ubuntu systems, this allows the usage of `service watchmen start`.

Watchmen already include a `Procfile` so you can also manage with `nf`.

```
$ npm install -g foreman
$ nf start
```

To export as an Upstart script using the environment variables in a `.env` file:

```
$ PATH="/home/user/.nvm/versions/v5.1.0/bin:$PATH" nf export -o /etc/init -a watchmen
```

You can run this without the `-o /etc/init` flag and move the files to this
directory (or the appropriate Upstart) directory yourself. Make sure you have
the correct path to the `node` bin, you can find out with `which node`.

More documentation on `node-foreman`:

https://github.com/strongloop/node-foreman

## Configuration

Config is set through ``env`` variables.

Have a look at the /config folder for more details, but the general parameters are:

```sh
export WATCHMEN_BASE_URL='http://watchmen.letsnode.com'
export WATCHMEN_WEB_PORT='8080'
export WATCHMEN_ADMINS='admin@domain.com'
export WATCHMEN_GOOGLE_ANALYTICS_ID='your-GA-ID'
```

### Authorization settings (since 2.2.0)

Watchmen uses Google Auth through passportjs for authentication. If your google email is present in ``WATCHMEN_ADMINS`` env variable, you will be able to **manage services**.

Make sure you set the right hostname so the OAuth dance can be negociated correctly:

```sh
export WATCHMEN_BASE_URL='http://watchmen.letsnode.com/'
```

You will also need to set the Google client ID and secret using ``env`` variables accordingly. (Login into https://console.developers.google.com/ to create them first)

```sh
export WATCHMEN_GOOGLE_CLIENT_ID='<your key>'
export WATCHMEN_GOOGLE_CLIENT_SECRET='<your secret>'
```

## Disabling authentication

If you want to disable authentication access and let anyone access and edit your services use:

```
export WATCHMEN_WEB_NO_AUTH='true'
```

## Ping services

### Embedded ping services

#### HTTP-HEAD

https://www.npmjs.com/package/watchmen-ping-http-head

#### HTTP-CONTAINS

https://www.npmjs.com/package/watchmen-ping-http-contains

### Third party contributions

#### NightmareJS Plugin for Watchmen

Allows Nightmare scripts to be executed by a Watchmen instance
https://www.npmjs.com/package/watchmen-ping-nightmare

### Creating your own ping service

Ping services are npm modules with the ``'watchmen-ping'`` prefix.

For example, if you want to create a smtp ping service:

#### a) create a watchmen-ping-smtp module and publish it. This is how a simple HTTP ping service looks like:

```javascript
var request = require('request');

function PingService(){}

exports = module.exports = PingService;

PingService.prototype.ping = function(service, callback){
  var startTime = +new Date();
  request.get({ method: 'HEAD', uri: service.url }, function(error, response, body){
    callback(error, body, response, +new Date() - startTime);
  });
};

PingService.prototype.getDefaultOptions = function(){
  return {}; // there is not need for UI confi options for this ping service
}
```

#### b) npm install it in watchmen:

```sh
     npm install watchmen-ping-smtp
```

#### c) create a service that uses that ping service

![Select ping service](https://github.com/iloire/watchmen/raw/master/screenshots/ping-service-selection.png)

## Monitor plugins

### AWS SES Notifications plugin (provided)

https://github.com/iloire/watchmen-plugin-aws-ses

#### Settings

```sh
export WATCHMEN_AWS_FROM='your@email'
export WATCHMEN_AWS_REGION='your AWS region'
export WATCHMEN_AWS_KEY='your AWS Key'
export WATCHMEN_AWS_SECRET='your AWS secret'

```

### Nodemailer Notifications plugin (third party contribution)

https://www.npmjs.com/package/watchmen-plugin-nodemailer

### Slack Notifications plugin (third party contribution)

https://www.npmjs.com/package/watchmen-plugin-slack

### Console output plugin (provided)

https://github.com/iloire/watchmen-plugin-console

### Creating your own custom plugin

A ``watchmen`` instance will be injected through your plugin constructor. Then you can subscribe to the desired events. Best is to show it through an example.

This what the console plugin looks like:

```javascript
var colors = require('colors');
var moment = require('moment');

var eventHandlers = {

  /**
   * On a new outage
   * @param {Object} service
   * @param {Object} outage
   * @param {Object} outage.error check error
   * @param {number} outage.timestamp outage timestamp
   */

  onNewOutage: function (service, outage) {
    var errorMsg = service.name + ' down!'.red + '. Error: ' + JSON.stringify(outage.error).red;
    console.log(errorMsg);
  },

  /**
   * Failed ping on an existing outage
   * @param {Object} service
   * @param {Object} outage
   * @param {Object} outage.error check error
   * @param {number} outage.timestamp outage timestamp
   */

  onCurrentOutage: function (service, outage) {
    var errorMsg = service.name + ' is still down!'.red + '. Error: ' + JSON.stringify(outage.error).red;
    console.log(errorMsg);
  },

  /**
   * Failed check (it will be an outage or not according to service.failuresToBeOutage
   * @param {Object} service
   * @param {Object} data
   * @param {Object} data.error check error
   * @param {number} data.currentFailureCount number of consecutive check failures
   */

  onFailedCheck: function (service, data) {
    var errorMsg = service.name + ' check failed!'.red + '. Error: ' + JSON.stringify(data.error).red;
    console.log(errorMsg);
  },

  /**
   * Warning alert
   * @param {Object} service
   * @param {Object} data
   * @param {number} data.elapsedTime (ms)
   */

  onLatencyWarning: function (service, data) {
    var msg = service.name + ' latency warning'.yellow + '. Took: ' + (data.elapsedTime + ' ms.').yellow;
    console.log(msg);
  },

  /**
   * Service is back online
   * @param {Object} service
   * @param {Object} lastOutage
   * @param {Object} lastOutage.error
   * @param {number} lastOutage.timestamp (ms)
   */

  onServiceBack: function (service, lastOutage) {
    var duration = moment.duration(+new Date() - lastOutage.timestamp, 'seconds');
    console.log(service.name.white + ' is back'.green + '. Down for '.gray + duration.humanize().white);
  },

  /**
   * Service is responding correctly
   * @param {Object} service
   * @param {Object} data
   * @param {number} data.elapsedTime (ms)
   */

  onServiceOk: function (service, data) {
    var serviceOkMsg = service.name + ' responded ' + 'OK!'.green;
    var responseTimeMsg = data.elapsedTime + ' ms.';
    console.log(serviceOkMsg, responseTimeMsg.gray);
  }
};

function ConsolePlugin(watchmen) {
  watchmen.on('new-outage', eventHandlers.onNewOutage);
  watchmen.on('current-outage', eventHandlers.onCurrentOutage);
  watchmen.on('service-error', eventHandlers.onFailedCheck);

  watchmen.on('latency-warning', eventHandlers.onLatencyWarning);
  watchmen.on('service-back', eventHandlers.onServiceBack);
  watchmen.on('service-ok', eventHandlers.onServiceOk);
}

exports = module.exports = ConsolePlugin;
```

## Storage providers

### Redis

#### Data schema

```
service - set with service id's
service:latestOutages - latest outages for all services
service:<serviceId> - hashMap with service details
service:<serviceId>:outages:current - current outage for a service (if any)
service:<serviceId>:outages - sorted set with outages info
service:<serviceId>:latency - sorted set with latency info
service:<serviceId>:failurecount - number of consecutive pings failures (to determine if it is an outage)
```

### Configuration

```sh
export WATCHMEN_REDIS_PORT_PRODUCTION=1216
export WATCHMEN_REDIS_DB_PRODUCTION=1

export WATCHMEN_REDIS_PORT_DEVELOPMENT=1216
export WATCHMEN_REDIS_DB_DEVELOPMENT=2
```

## Using fake data for development

```sh
cd scripts
sh populate-dummy-data-120days.sh # will populate data for a 120 day period
```

or

```sh
sh populate-dummy-data-30days.sh
```

etc..


## Running with docker

To run with docker, make sure you have docker-compose installed: https://docs.docker.com/compose/install/

Also, have a docker host running. A good way is using docker-machine with a local VM: https://docs.docker.com/machine/get-started/

Edit ``docker-compose.env`` and set up the configuration.

Then, to build and run Watchmen, run the following:

```
docker-compose build
docker-compose up
```

After this Watchmen webserver will be running and exposed in the port 3000 of the docker host.

To configure, please look `docker-compose.yml` and `docker-compose.env`.

## Terraform scripts for digital-ocean

You can deploy watchmen in a Digital Ocean droplet in a matter of minutes.

1. Install terraform from [terraform.io](https://www.terraform.io/).
2. If you don't have one yet, create an account in Digital Ocean. Use [this link](https://m.do.co/c/23602cbcfcc3) to get an initial $10 credit so you can play around with it for free.
3. Open a terminal in ``terraform/digital-ocean``
4. Fill up ``user-data.yml`` with your configuration. Don't forget to also setup ``DIGITALOCEAN_TOKEN`` and ``SSH_FINGERPRINT`` env variables (see apply.sh):
5. Run ``sh apply.sh`` to create your droplet.

Terraform will create a droplet based on Ubuntu with the necessary packages, compile nodejs from source, install a redis server, install and configure an nginx in front of watchmen, and setup and run watchmen from the latest master using [pm2](https://github.com/Unitech/pm2).

![watchmen droplet](https://github.com/iloire/watchmen/raw/master/screenshots/watchmen-droplet-01.png)

## Tests

```sh
$ npm test
```

### Test coverage

```sh
$ npm run coverage
```

Then check the coverage reports:

```sh
$ open coverage/lcov-report/lib/index.html
```

![watchmen test coverage](https://github.com/iloire/watchmen/raw/master/screenshots/test-coverage-node-01.png)

## Debugging

watchmen uses [debug](https://www.npmjs.com/package/debug)

```sh
set DEBUG=*
```

