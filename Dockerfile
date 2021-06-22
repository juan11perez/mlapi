FROM phusion/baseimage:master

ENV	OPEN_CV_VERSION="4.5.2" \
	MAKE_THREADS="12" \
	APP_DIR="/var/lib/zmeventnotification" \
	NVIDIA_VISIBLE_DEVICES="all" \
	NVIDIA_DRIVER_CAPABILITIES="compute,utility,video"

COPY init/ /etc/my_init.d/

RUN 	apt-get update && DEBIAN_FRONTEND=noninteractive \
	apt-get -y install --no-install-recommends software-properties-common runit-systemd && \
	apt-get -y install curl wget git ffmpeg build-essential cmake unzip pkg-config libjpeg-dev libpng-dev libtiff-dev libavcodec-dev \
	libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libgtk-3-dev libatlas-base-dev gfortran python3-dev python3-pip ca-certificates \
	python3 python-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev &&\
	pip3 install numpy && \
	apt-get clean autoclean && \
	apt-get autoremove --yes && \
	rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
	cd /root && \
	wget -q -O opencv.zip https://github.com/opencv/opencv/archive/${OPEN_CV_VERSION}.zip && \
	wget -q -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${OPEN_CV_VERSION}.zip && \
	unzip opencv.zip && \
	unzip opencv_contrib.zip && \
	mv $(ls -d opencv-*) opencv && \
	mv opencv_contrib-${OPEN_CV_VERSION} opencv_contrib && \
	rm *.zip && \
	cd /root/opencv && \
	mkdir build && \
	cd build && \
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_PYTHON_EXAMPLES=OFF -D INSTALL_C_EXAMPLES=OFF -D OPENCV_ENABLE_NONFREE=ON -D OPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib/modules -D HAVE_opencv_python3=ON -D PYTHON_EXECUTABLE=/usr/bin/python3 -D PYTHON2_EXECUTABLE=/usr/bin/python2 -D BUILD_EXAMPLES=OFF .. >/dev/null && \
	make -j4 && \
	make install && \
	cd /root && \
	rm -r opencv* && \
	mkdir -p ${APP_DIR} && \
	chmod 777 ${APP_DIR}

#Set the workdir
WORKDIR ${APP_DIR}

RUN	apt-get -y install python3-pip && \
	apt-get -y install libopenblas-dev liblapack-dev libblas-dev libev-dev libevdev2 curl gnupg gnupg2 gnupg1 && \
	cd /var/lib/zmeventnotification/ && \
	git clone https://github.com/pliablepixels/mlapi.git . && git fetch --tags && \
	git checkout $(git describe --tags $(git rev-list --tags --max-count=1)) && \
    	pip3 install -r requirements.txt && \
	pip3 install face_recognition && \
	cd /var/lib/zmeventnotification/ && \
	mkdir -p models/tinyyolov3 && \
	wget https://pjreddie.com/media/files/yolov3-tiny.weights -O models/tinyyolov3/yolov3-tiny.weights && \
	wget https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3-tiny.cfg -O models/tinyyolov3/yolov3-tiny.cfg && \
	wget https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names -O models/tinyyolov3/coco.names && \
	mkdir -p models/yolov3 && \
	wget https://raw.githubusercontent.com/pjreddie/darknet/master/cfg/yolov3.cfg -O models/yolov3/yolov3.cfg && \
	wget https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names -O models/yolov3/coco.names && \
	wget https://pjreddie.com/media/files/yolov3.weights -O models/yolov3/yolov3.weights && \
	mkdir -p models/tinyyolov4 && \
	wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v4_pre/yolov4-tiny.weights -O models/tinyyolov4/yolov4-tiny.weights && \
	wget https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4-tiny.cfg -O models/tinyyolov4/yolov4-tiny.cfg && \
	wget https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names -O models/tinyyolov4/coco.names && \
	mkdir -p models/yolov4 && \
	wget https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4.cfg -O models/yolov4/yolov4.cfg && \
	wget https://raw.githubusercontent.com/pjreddie/darknet/master/data/coco.names -O models/yolov4/coco.names && \
	wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights -O models/yolov4/yolov4.weights && \
	mkdir -p models/coral_edgetpu && \
	wget https://dl.google.com/coral/canned_models/coco_labels.txt -O models/coral_edgetpu/coco_indexed.names && \
	wget https://github.com/google-coral/edgetpu/raw/master/test_data/ssd_mobilenet_v2_coco_quant_postprocess_edgetpu.tflite -O models/coral_edgetpu/ssd_mobilenet_v2_coco_quant_postprocess_edgetpu.tflite && \
	wget https://github.com/google-coral/test_data/raw/master/ssdlite_mobiledet_coco_qat_postprocess_edgetpu.tflite -O models/coral_edgetpu/ssdlite_mobiledet_coco_qat_postprocess_edgetpu.tflite && \
	wget https://github.com/google-coral/test_data/raw/master/ssd_mobilenet_v2_face_quant_postprocess_edgetpu.tflite -O models/coral_edgetpu/ssd_mobilenet_v2_face_quant_postprocess_edgetpu.tflite && \
    	apt-get clean autoclean && \
    	apt-get autoremove --yes && \
   	rm -rf /var/lib/{apt,dpkg,cache,log}

# install coral usb libraries
RUN 	apt-get update && echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list && \
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
	apt-get update && apt-get -y install gasket-dkms libedgetpu1-std python3-pycoral &&\
	apt install -y syslog-ng && \
	sed -i s#3.13#3.25#g /etc/syslog-ng/syslog-ng.conf && \
	sed -i 's#use_dns(no)#use_dns(yes)#' /etc/syslog-ng/syslog-ng.conf

VOLUME \
	["/config"]

EXPOSE 5000

CMD ["/sbin/my_init"]
