curl -XPOST camel-toolbox:9080/reindexing -H"Content-Type: application/json" \
    -d '["broker:queue:fixity"]'