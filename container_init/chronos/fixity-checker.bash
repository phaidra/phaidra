# functions

function get_fedora_objects {
    curl --silent \
         --user "$FEDORA_ADMIN_USER:$FEDORA_ADMIN_PASS" \
         http://${FEDORA_HOST}:8080/fcrepo/rest/fcr:search | \
        jq .items[].fedora_id | \
        tr -d '"' | \
        grep -vE "fcr:metadata|[0-9]$"
}

function get_fixity_result {
    curl --silent \
         --user "$FEDORA_ADMIN_USER:$FEDORA_ADMIN_PASS" \
         -H "accept:application/ld+json" \
         "$1/fcr:fixity" | \
        jq -r '.[1]."http://www.loc.gov/premis/rdf/v1#hasEventOutcome"[]."@value"'
}

function get_sha512sum {
    curl --silent \
         --user "$FEDORA_ADMIN_USER:$FEDORA_ADMIN_PASS" \
         -H "accept:application/ld+json" \
         "$1/fcr:fixity" | \
        jq -r '.[1]."http://www.loc.gov/premis/rdf/v1#hasMessageDigest"[]."@id"' | \
        sed 's|urn:sha-512:||'
}

function get_ocfl_topdir {
    DIGEST=$(printf "info:fedora/$(printf $1 | cut -d '/' -f 6)" | sha256sum | cut -d ' ' -f 1)
    printf "${DIGEST:0:3}/${DIGEST:3:3}/${DIGEST:3:6}/${DIGEST}\n"
}

function init_database {
    mysql -h ${MARIADB_PHAIDRA_HOST} \
          -u root \
          -p${MARIADB_PHAIDRA_ROOT_PASSWORD} \
          $PHAIDRADB \
          -e \
          "CREATE TABLE IF NOT EXISTS fixity_states
(fedora_id varchar(250) NOT NULL,
fedora_fixity char(20) NOT NULL,
last_check datetime NOT NULL,
expected_sha512sum varchar(250) NOT NULL,
ocfl_topdir varchar(250) NOT NULL,
PRIMARY KEY (fedora_id))"
}

function update_database {
    mysql -h ${MARIADB_PHAIDRA_HOST} \
          -u root \
          -p${MARIADB_PHAIDRA_ROOT_PASSWORD} \
          $PHAIDRADB \
          -e \
          "INSERT INTO fixity_states \
(fedora_id,fedora_fixity,expected_sha512sum,ocfl_topdir,last_check) \
VALUES('${1}','${2}','${3}','${4}',NOW()) \
ON DUPLICATE KEY UPDATE \
fedora_id='${1}', \
fedora_fixity='${2}', \
expected_sha512sum='${3}', \
ocfl_topdir='${4}', \
last_check=NOW()"
}

# algorithm
init_database
FEDORA_OBJECTS=$(get_fedora_objects)
printf 'Number of objects to check:  %d\n' $(wc -w <<< $FEDORA_OBJECTS)
for FILE_OBJECT in $FEDORA_OBJECTS
do
    if [[ "${FILE_OBJECT}" == *"JSON-LD"* || "${FILE_OBJECT}" == *"OCTETS"* || "${FILE_OBJECT}" == *"WEBVERSION"* || "${FILE_OBJECT}" == *"JSON-LD-PRIVATE"* || "${FILE_OBJECT}" == *"UWMETADATA"* || "${FILE_OBJECT}" == *"MODS"* || "${FILE_OBJECT}" == *"RIGHTS"* || "${FILE_OBJECT}" == *"COLLECTIONORDER"* || "${FILE_OBJECT}" == *"LINK"* || "${FILE_OBJECT}" == *"IIIF-MANIFEST"* || "${FILE_OBJECT}" == *"ANNOTATIONS"* ]]
    then
        RESULT=$(get_fixity_result $FILE_OBJECT)
        printf "Fixity check for $FILE_OBJECT: $RESULT\n"
        SHA512SUM=$(get_sha512sum $FILE_OBJECT)
        OCFL_TOPDIR=$(get_ocfl_topdir $FILE_OBJECT)
        update_database $FILE_OBJECT $RESULT $SHA512SUM $OCFL_TOPDIR
    fi
done
