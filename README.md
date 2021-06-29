# mlapi
Docker container for https://github.com/pliablepixels/mlapi

Start the container:
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

Create user in the persistent config volume with below commands:
```
docker exec -it mlapi /bin/bash
```
```
cd /config && python3 /var/lib/zmeventnotification/mlapi_dbuser.py
```
```
exit
```

At this time modify secrets.ini and mlapiconfig.ini in /config. ***If you restart without modifying these files the containe will fail.***   
   
Restart the container.

The docker incorporates yolov and coral models as well as Open CV built from source.
