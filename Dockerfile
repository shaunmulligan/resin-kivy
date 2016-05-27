# Use base image for device arch with python installed
FROM resin/raspberrypi-python:2.7.11-20160520

ENV INITSYSTEM=on

RUN echo "deb http://vontaene.de/raspbian-updates/ . main" >> /etc/apt/sources.list
RUN gpg --keyserver pgp.mit.edu --recv-keys 0C667A3E
RUN gpg -a --export 0C667A3E | sudo apt-key add -

RUN apt-get update && apt-get install -yq \
    libraspberrypi-dev libraspberrypi-bin libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
    pkg-config libgl1-mesa-dev libgles2-mesa-dev mtdev-tools\
    python-pygame python-setuptools libgstreamer1.0-dev git-core \
    gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly \
    gstreamer1.0-alsa gstreamer1.0-omx python-dev cython && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# EGL work around for containers
WORKDIR /opt/vc
RUN wget https://github.com/resin-io-playground/userland/releases/download/v0.1/userland-rpi.tar.xz
RUN tar xf userland-rpi.tar.xz

# create src dir
RUN mkdir -p /usr/src/app/
ENV KIVY_HOME=/usr/src/app
# set as WORKDIR
WORKDIR /usr/src/app
COPY config.ini config.ini

# pip install python deps from requirements.txt on the resin.io build server
#RUN pip install -r /requirements.txt
RUN pip install pygments docutils
#cython==0.23

RUN git clone https://github.com/kivy/kivy && cd kivy && python setup.py build && python setup.py install

# Copy all of files here for caching purposes
COPY . ./

# runs the start script on container start
CMD ["python", "main.py"]
