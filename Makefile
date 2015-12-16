TMPDIR=/tmp
TMPFILE=$(TMPDIR)/docker-host-ip

all: build run

build:
	docker build -t hooktest .

clean:
	docker rmi hooktest

run:
	docker run --rm -e PASSENGER_APP_ENV=dev -e SECRET_TOKEN=mysecret -e JENKINS_HOST=example.com -p 80:80 hooktest

# Uses httpie
ping:
	@docker-machine ip default > $(TMPFILE)
# TODO: replace with a POST that looks like the one from GitHub
	@http POST http://`cat $(TMPFILE)`/jenkins name=John email=john@example.org
