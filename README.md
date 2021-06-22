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
```   
   
To start the server first time type below:

Create user
```
docker exec -it mlapi python3 mlapi_dbuser.py
```

Start service
```
docker exec -itd mlapi python3 ./mlapi.py -c mlapiconfig.ini
```

The docker incorporates all models (including coral) as well as Open CV built from source.
