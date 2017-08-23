# OpenCV Jupyter Notebooks

This repository builds a container image that includes the Jupyter Data
Science notebook platform.  It then builds and installs OpenCV along with
its Python bindings.

### Building

```bash
docker build -t opencv-notebooks .
```

### Running from Linux

The default user for the container is `jovyan` and the password for
`sudo` access is ``.

#### With access to host X server

Forward the Unix X11 socket and pass the DISPLAY environment variable to
the container: `-v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY`.

```bash
docker run -it --rm -p 8888:8888 -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd):/home/jovyan/local -e DISPLAY opencv-notebook
```

#### With access to host devices and X server

In addition to the X server forwarding, add arguments to forward the
/dev/video device and to establish priviledged operation: `--privileged --device /dev/video0`.

```bash
docker run -it --rm --privileged --device /dev/video0 -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd):/home/jovyan/local -e DISPLAY opencv-notebooks
```

### Notebooks

#### Generating a network stream from a webcam on a Linux host

In order to create a network stream on a Linux host, use VLC.  The `cvlc`
command line version of this command can be used once the stream
parameters have been determined.  This includes the codecs to use as well
as the device specifications and stream identity.

For example, the following command will capture a video stream from the
/dev/video0 device, an audio stream from also://hw:0,0, stream with a
cache of 300 frames, use the WMV2 codec, wma2 audio codec with 2 channels
and a sample rate of 44.1kbits.  The stream is located using the `http`
protocol on the host interface as: `http://0.0.0.0:2112/stream.wmv`. This
allows any interface on the host to reach the stream.

Note that a container will need to specify the host IP address to reach
this stream as localhost for the host is not reachable.  Determine the
host IP address uing `ifconfig`.

```bash
/usr/bin/env cvlc v4l2:///dev/video0 ':v4l2-standard= :input-slave=alsa://hw:0,0 :live-caching=300' ':sout=#transcode{vcodec=WMV2,vb=800,acodec=wma2,ab=128,channels=2,samplerate=44100}:http{dst=:2112/stream.wmv}'

```

#### Accessing a network stream from the host

