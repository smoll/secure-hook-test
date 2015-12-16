TMPDIR=/tmp
TMPFILE=$(TMPDIR)/docker-host-ip

all: build run

build:
	docker build -t hooktest .

clean:
	docker rmi hooktest

run:
	docker run --rm -e PASSENGER_APP_ENV=dev -p 80:80 hooktest

ping:
	@docker-machine ip default > $(TMPFILE)
	@curl http://`cat $(TMPFILE)`
