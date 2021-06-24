# mlapi
Docker container for https://github.com/pliablepixels/mlapi

Modify 
mlapiconfig.ini to your requirements.

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
    command: python3 ./mlapi.py -c mlapiconfig.ini    
```   
Image creates default user:admin password:admin   
   
To modify the user, type below command. If the container is re-created you will need to re-create your specifc user.

```
docker exec -it mlapi python3 mlapi_dbuser.py
```

Start service manually
```
docker exec -itd mlapi python3 ./mlapi.py -c mlapiconfig.ini
```


The docker incorporates yolov and coral models as well as Open CV built from source.





