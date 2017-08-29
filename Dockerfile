FROM abernix/meteord:base

FROM ubuntu:16.04

RUN apt-get update
RUN apt-get -y install ffmpeg