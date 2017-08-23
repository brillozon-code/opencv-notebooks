
FROM jupyter/datascience-notebook

USER root

# Reference: http://www.pyimagesearch.com/2016/10/24/ubuntu-16-04-how-to-install-opencv/

RUN \ 
     apt-get -qq update && apt-get -qq upgrade -y \
  && apt-get -qq install -y \
                 build-essential \
                 libtbb-dev \
  && apt-get -qq install -y \
                 cmake \
                 pkg-config \
                 libjpeg8-dev \
                 libtiff5-dev \
                 libjasper-dev \
                 libpng12-dev \
                 libavcodec-dev \
                 libavformat-dev \
                 libswscale-dev \
                 libv4l-dev \
                 libxvidcore-dev \
                 libx264-dev \
                 libgtk-3-dev \
                 libatlas-base-dev \
                 gfortran \
                 libhdf5-dev \
                 python2.7-dev \
                 python3.5-dev \
                 python3-pip \
  && pip3 install --upgrade pip \
  && apt-get autoclean && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN \
     cd /home/jovyan \
  && wget https://github.com/Itseez/opencv/archive/3.2.0.zip \
  && unzip 3.2.0.zip \
  && mv /home/jovyan/opencv-3.2.0/ /home/jovyan/opencv/ \
  && rm -rf /home/jovyan/3.2.0.zip \

  && cd /home/jovyan \
  && wget https://github.com/opencv/opencv_contrib/archive/3.2.0.zip -O 3.2.0-contrib.zip \
  && unzip 3.2.0-contrib.zip \
  && mv opencv_contrib-3.2.0 opencv_contrib \
  && rm -rf /home/jovyan/3.2.0-contrib.zip \

     # HACK add conda lib to library search locations
  && export LD_LIBRARY_PATH=/opt/conda/lib \

  && cd /home/jovyan/opencv \
  && mkdir build \
  && cd build \
  && cmake -D CMAKE_BUILD_TYPE=RELEASE \
           -D CMAKE_INSTALL_PREFIX=/usr/local \
           -D INSTALL_C_EXAMPLES=OFF \
           -D PYTHON_EXECUTABLE=/opt/conda/bin/python \
           -D PYTHON_LIBRARY=/opt/conda/lib \
           -D PYTHON_INCLUDE_DIR=/opt/conda/include/python3.6m \
           -D INSTALL_PYTHON_EXAMPLES=ON \
           -D OPENCV_EXTRA_MODULES_PATH=/home/jovyan/opencv_contrib/modules \
           -D BUILD_EXAMPLES=ON .. \

  && cd /home/jovyan/opencv/build \
  && make -j $(nproc) \
  && make install \
  && ldconfig \

     # clean opencv repos
  && rm -rf /home/jovyan/opencv/build \
  && rm -rf /home/jovyan/opencv/3rdparty \
  && rm -rf /home/jovyan/opencv/doc \
  && rm -rf /home/jovyan/opencv/include \
  && rm -rf /home/jovyan/opencv/platforms \
  && rm -rf /home/jovyan/opencv/modules \
  && rm -rf /home/jovyan/opencv_contrib/build \
  && rm -rf /home/jovyan/opencv_contrib/doc

# HACK!
RUN ln -s \
     /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so \
     /opt/conda/lib/python3.6/site-packages/

RUN chown -R jovyan.users /home/jovyan/opencv

USER jovyan

