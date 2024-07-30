FROM solr:9.6.1
ADD ../container_init/solr/log4j2.xml /tmp/log4j2.xml
ADD ../container_init/solr/security.json /tmp/security.json
ADD ../container_init/solr/phaidra_core /tmp/phaidra_core_init
ADD ../container_init/solr/solr_entrypoint_dist.bash /tmp/solr_entrypoint_dist.bash
ENTRYPOINT ["bash", "/tmp/solr_entrypoint_dist.bash"]
