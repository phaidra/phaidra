FROM testuser34/chronos-base:latest
ADD ../container_init/chronos /mnt/chronos
ENTRYPOINT ["bash","/mnt/chronos/chronos-entrypoint.bash"]
