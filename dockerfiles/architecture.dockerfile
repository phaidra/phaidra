FROM ubuntu:jammy-20231211.1
ENV DEBIAN_FRONTEND noninteractive
RUN dpkg --print-architecture
