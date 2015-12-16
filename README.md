#### use automated build
```
docker run -e PASSENGER_APP_ENV=staging -p 80:80 smoll/secure-hook-test:latest
```

#### build
```
docker build -t hooktest .
```
#### run
```
docker run -e PASSENGER_APP_ENV=dev -p 80:80 hooktest
```
