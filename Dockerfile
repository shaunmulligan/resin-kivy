# Use base image for device arch with python installed
FROM resin/raspberrypi-python:2.7.11-20160520

ENV INITSYSTEM=on

# EGL work around for containers
WORKDIR /opt/vc
RUN wget https://github.com/resin-io-playground/userland/releases/download/v0.1/userland-rpi.tar.xz
RUN tar xf userland-rpi.tar.xz

RUN echo "deb http://vontaene.de/raspbian-updates/ . main" | sudo tee --append /etc/apt/sources.list
RUN gpg --keyserver pgp.mit.edu --recv-keys 0C667A3E && gpg -a --export 0C667A3E | sudo apt-key add -

RUN apt-get update && apt-get install -yq \
    pkg-config libgl1-mesa-dev libgles2-mesa-dev \
    python-pygame python-setuptools libgstreamer1.0-dev git-core \
    gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly \
    gstreamer1.0-omx gstreamer1.0-alsa python-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# create src dir
RUN mkdir -p /usr/src/app/

# set as WORKDIR
WORKDIR /usr/src/app

# Copy requirements.txt first for better cache on later pushes
#COPY ./requirements.txt /requirements.txt

# pip install python deps from requirements.txt on the resin.io build server
#RUN pip install -r /requirements.txt
RUN pip install cython pygments docutils

RUN git clone https://github.com/kivy/kivy && cd kivy && python setup.py build && python setup.py install

# Copy all of files here for caching purposes
COPY . ./

# runs the start script on container start
CMD ["ls -la"]
