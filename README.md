#### use automated build
```
docker run -e PASSENGER_APP_ENV=staging -e SECRET_TOKEN=mysecret -p 80:80 smoll/secure-hook-test:latest
```

#### build
```
docker build -t hooktest .
```

#### run
```
docker run -e PASSENGER_APP_ENV=dev -e SECRET_TOKEN=mysecret -p 80:80 hooktest
```

#### testing

In one terminal, bring up the app, which also tails `stdout`

```bash
$ make
# ...
All Phusion Passenger agents started!
```

##### set up hosts file

```
$ docker-machine ip default
192.168.99.100
```

I have two, but you only need one entry

```bash
# /etc/hosts
192.168.99.100  b2d
192.168.99.100  docker.local
```

##### setup ngrok

```
$ brew install ngrok
==> Pouring ngrok-1.7.1.yosemite.bottle.tar.gz
🍺  /usr/local/Cellar/ngrok/1.7.1: 4 files, 11M
```

In a separate terminal

```
$ ngrok docker.local:80

ngrok                         (Ctrl+C to quit)

Tunnel Status                 online
Version                       1.7/1.7
Forwarding                    http://abc123.ngrok.com -> docker.local:80
Forwarding                    https://abc123.ngrok.com -> docker.local:80
Web Interface                 127.0.0.1:4040
# Conn                        7
Avg Conn Time                 217.65ms
```

##### send a test POST from GitHub

Set up the webhook in the GitHub UI

* Payload URL: `http://abc123.ngrok.com/payload`
* Content type: `application/json`
* Secret: `mysecret`

_(the rest can be default, or configured to taste)_

Also see [this article](https://developer.github.com/webhooks/testing/).

##### don't forget to test the failure scenario

Same as above, except

* Secret: `wrong`
