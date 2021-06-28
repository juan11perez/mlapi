#!/bin/bash
#
# 40_firstrun.sh
#
#
# Github URL for opencv zip file download.
# Current default is to pull the version 4.5.2 release.
#
# Search for config files, if they don't exist, create the default ones

# Handle the secrets.ini file
mkdir -p /etc/zm
if [ -f /var/lib/zmeventnotification/secrets.ini ]; then
	echo "Moving secrets.ini"
	cp /var/lib/zmeventnotification/secrets.ini /config/secrets.ini.default
	if [ ! -f /config/secrets.ini ]; then
		mv /var/lib/zmeventnotification/secrets.ini /config/secrets.ini
	else
		rm -rf /var/lib/zmeventnotification/secrets.ini
	fi
else
	echo "File secrets.ini already moved"
fi

# Handle the mlapiconfig.ini file
if [ -f /var/lib/zmeventnotification/mlapiconfig.ini ]; then
	echo "Moving mlapiconfig.ini"
	cp /var/lib/zmeventnotification/mlapiconfig.ini /config/mlapiconfig.ini.default
	if [ ! -f /config/mlapiconfig.ini ]; then
		mv /var/lib/zmeventnotification/mlapiconfig.ini /config/mlapiconfig.ini
	else
		rm -rf /var/lib/zmeventnotification/mlapiconfig.ini
	fi
else
	echo "File mlapiconfig.ini already moved"
fi

# Create opencv folder if it doesn't exist
if [ ! -d /config/opencv ]; then
	echo "Creating opencv folder in config folder"
	mkdir /config/opencv
fi

# # Handle db dir
# if [ -d /var/lib/zmeventnotification/db ]; then
# 	echo "Moving db dir"
# 	mv /var/lib/zmeventnotification/db /config/
# else
# 	echo "Dir db already moved"
# fi

# # Symbolic link for db dir
# ln -sf /config/db/ /var/lib/zmeventnotification/

# Set ownership for unRAID
PUID=${PUID:-99}
PGID=${PGID:-100}
usermod -o -u $PUID nobody

# Check if the group with GUID passed as environment variable exists and create it if not.
if ! getent group "$PGID" >/dev/null; then
  groupadd -g "$PGID" env-provided-group
  echo "Group with id: $PGID did not already exist, so we created it."
fi

usermod -g $PGID nobody
usermod -d /config nobody

# Change some ownership and permissions
chown -R $PUID:$PGID /config/secrets.ini
chmod 666 /config/secrets.ini
chown -R $PUID:$PGID /config/mlapiconfig.ini
chmod 666 /config/mlapiconfig.ini
chown -R $PUID:$PGID /config/opencv
chmod 777 /config/opencv

# Symbolink for /config/secrets.ini
ln -sf /config/secrets.ini /etc/zm/

# Symbolink for /config/mlapiconfig.ini
ln -sf /config/mlapiconfig.ini /var/lib/zmeventnotification/

# Create hook folder
if [ ! -d /config/hook ]; then
	echo "Creating /config/hook folder"
	mkdir /config/hook
fi

# Create known_faces folder if it doesn't exist
if [ ! -d /config/hook/known_faces ]; then
	echo "Creating hook/known_faces folder in config folder"
	mkdir -p /config/hook/known_faces
fi

# Create unknown_faces folder if it doesn't exist
if [ ! -d /config/hook/unknown_faces ]; then
	echo "Creating hook/unknown_faces folder in config folder"
	mkdir -p /config/hook/unknown_faces
fi

# Symbolic link for known_faces in /config
rm -rf /var/lib/zmeventnotification/known_faces
ln -sf /config/hook/known_faces /var/lib/zmeventnotification/known_faces
chown -R www-data:www-data /var/lib/zmeventnotification/known_faces

# Symbolic link for unknown_faces in /config
rm -rf /var/lib/zmeventnotification/unknown_faces
ln -sf /config/hook/unknown_faces /var/lib/zmeventnotification/unknown_faces
chown -R www-data:www-data /var/lib/zmeventnotification/unknown_faces

# Create coral_edgetpu folder if it doesn't exist
if [ ! -d /config/hook/coral_edgetpu ]; then
	echo "Creating hook/coral_edgetpu folder in config folder"
	mkdir -p /config/hook/coral_edgetpu
fi

# Handle the coco_indexed.names file
if [ -f /var/lib/zmeventnotification/models/coral_edgetpu/coco_indexed.names ]; then
	echo "Moving mcoco_indexed.names"
	mv /var/lib/zmeventnotification/models/coral_edgetpu/coco_indexed.names /config/hook/coral_edgetpu/
else
	echo "Dir coral_edgetpu already moved"
fi

# Symbolic link for coral_edgetpu in /config
ln -sf /config/hook/coral_edgetpu/coco_indexed.names /var/lib/zmeventnotification/models/coral_edgetpu/
chown -R www-data:www-data /var/lib/zmeventnotification/models/coral_edgetpu 2>/dev/null

# Set hook folder permissions
chown -R $PUID:$PGID /config/hook
chmod -R 777 /config/hook

# start service
if [ -f  /var/lib/zmeventnotification/db/db.json ]; then
	echo "Starting services..."
	python3 /var/lib/zmeventnotification/mlapi.py -c mlapiconfig.ini
fi
