# OpenCV Jupyter Notebooks

This repository builds a container image that includes the Jupyter Data
Science notebook platform.  It then builds and installs OpenCV along with
its Python bindings.

The container image is based on the
[jupyter/datascience-notebook:37af02395694](https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook)
image from 8/16/2017.  This image is based on the Ubuntu 16.04 (xenial)
distribution.

In addition, the [Theano](http://deeplearning.net/software/theano/)
and [Tensorflow](https://www.tensorflow.org/) Deep Learning libraries have been installed.

The OpenCV libraries are built from the [version 3.3.0 source
code](https://github.com/opencv/opencv) and [contributed
libraries](https://github.com/opencv/opencv_contrib).  The build
instructions found on
[`pyimagesearch`](http://www.pyimagesearch.com/2016/10/24/ubuntu-16-04-how-to-install-opencv/)
were used as a guide to the build.

The OpenCV Python 3.6 bindings were built and installed into the
notebooks Conda location (`/opt/conda`)

### Building

```bash
docker build -t opencv-notebooks .
```

### Running from Linux

The default user for the container is `jovyan`.  The datascience notebook
parent includes features that can be used at run time with this container
as well.  For example, granting `sudo` access to the user.

#### With access to host X server

Forward the Unix X11 socket and pass the DISPLAY environment variable to
the container: `-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY`.

```bash
docker run -it --rm -p 8888:8888 -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd):/home/jovyan/local -e DISPLAY brillozon/opencv-notebooks
```

#### With access to host devices and X server

In addition to the X server forwarding, add arguments to forward the
/dev/video device and to establish priviledged operation: `--privileged --device /dev/video0`.

```bash
docker run -it --rm --privileged --device /dev/video0 -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd):/home/jovyan/local -e DISPLAY brillozon/opencv-notebooks
```

#### Granting the user `sudo` access

The base notebook container image includes the ability to grant `sudo`
access to the user.  This can also be done when invoking this container.
This is done by setting the environment variable `GRANT_SUDO=yes` and
running the container with `--user root`.  Note that while the container
is executing as `root`, the notebook kernels are executing as the
`jovyan` user.

### Notebooks

Notebooks are included in the _notebooks_ directory and should be
executable as provided to demonstrate capabilties.  Some of the notebooks
expect some system or network resources to be available.  This includes
access to the X window resources of the host if the OpenCV `*show()`
functions are invoked.  Also, if a video device will be accessed, it will
need to be available in the container.

It may be easier to provide video from the capture device via a network
stream.  This can be done on different hosts using different techniques.
As long as the network endpoint is made available to the notebook(s),
they should work fine.

#### Generating a network stream from a webcam on a Linux host

In order to create a network stream on a Linux host, use VLC.  The `cvlc`
command line version of this command can be used once the stream
parameters have been determined.  This includes the codecs to use as well
as the device specifications and stream identity.

For example, the following command will capture a video stream from the
/dev/video0 device, an audio stream from alsa://hw:0,0, stream with a
cache of 300 frames, use the WMV2 codec, wma2 audio codec with 2 channels
and a sample rate of 44.1kbits.  The stream is located using the `http`
protocol on the host interface as: `http://0.0.0.0:2112/stream.wmv`. This
allows any interface on the host to reach the stream.

Note that a container will need to specify the host IP address to reach
this stream as localhost for the host is not reachable.  Determine the
host IP address using `ifconfig`.

```bash
/usr/bin/env cvlc v4l2:///dev/video0 ':v4l2-standard= :input-slave=alsa://hw:0,0 :live-caching=300' ':sout=#transcode{vcodec=WMV2,vb=800,acodec=wma2,ab=128,channels=2,samplerate=44100}:http{dst=:2112/stream.wmv}'

```

#### Accessing a network stream from the host

