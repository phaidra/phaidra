FROM testuser34/pixelgecko-base:latest
RUN echo hello
ADD ../src/pixelgecko /opt/pixelgecko

