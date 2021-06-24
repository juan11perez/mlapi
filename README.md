# mlapi
Docker container for https://github.com/pliablepixels/mlapi

Modify 
objectconfig.ini to your requirements.

To run the docker:

```
 mlapi:
    container_name: mlapi
    image: ghcr.io/juan11perez/mlapi
    restart: unless-stopped
    privileged: true
    hostname: UNRAID  
    volumes:
    - /mnt/cache/appdata/cctv/mlapi:/config
    ports:
    - "5000:5000"
   # command: python3 ./mlapi.py -c mlapiconfig.ini    
```   
   
To start the server first time:

Create user
```
docker exec -it mlapi python3 mlapi_dbuser.py
```

Start service
```
docker exec -itd mlapi python3 ./mlapi.py -c mlapiconfig.ini
```
Subsequent "automatic" starts

There's likely a better way to do this, but I dont know it and the folowing works:

start the container with "command: python3 ./mlapi.py -c mlapiconfig.ini" #uncommented. >> 
```
docker-compose up -d mlapi
```
Create user >> 
```
docker exec -it mlapi python3 mlapi_dbuser.py
```
Start service >> 
```
docker exec -itd mlapi python3 ./mlapi.py -c mlapiconfig.ini
```
Commit/save as follows:
get ContainerID with >> 
```
docker ps | grep "mlapi"
```
Save with >> 
```
docker commit <ContainerID> ghcr.io/juan11perez/mlapi
```
remove container
Uncomment "command: python3 ./mlapi.py -c mlapiconfig.ini" and start container 
```
docker-compose up -d mlapi
```


The docker incorporates yolov and coral models as well as Open CV built from source.
