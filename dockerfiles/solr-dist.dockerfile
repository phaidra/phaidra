FROM solr:9.2.1
RUN mkdir -pv /var/solr/data
ADD ../container_init/solr/log4j2.xml /var/solr/log4j2.xml
ADD ../container_init/solr/security.json /var/solr/data/security.json
ADD ../container_init/solr/phaidra_core /tmp/phaidra_core_init
ADD ../container_init/solr/solr_entrypoint_dist.bash /tmp/solr_entrypoint_dist.bash
ENTRYPOINT ["bash", "/tmp/solr_entrypoint_dist.bash"]
