FROM abernix/meteord:base

RUN apt-get update
RUN apt-get -y install ffmpeg