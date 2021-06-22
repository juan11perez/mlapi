# mlapi
Docker container for https://github.com/pliablepixels/mlapi

Modify 
objectconfig.ini to your requirements.

To run the server:

 `mlapi:
    container_name: mlapi
    image: mlapi
    restart: unless-stopped
    privileged: true
    hostname: UNRAID  
    volumes:
    - /mnt/cache/appdata/cctv/mlapi:/config
    ports:
    - "5000:5000"`

To start the server first time type below, it will prompt you to create at least one user.

docker exec -itd mlapi python3 ./mlapi.py -c mlapiconfig.ini


