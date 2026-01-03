#!/bin/bash

# Script to add all copyFields from managed-schema file to Solr via Schema API
# This adds all metadata fields (excluding extracted_text) to _text_

SOLR_URL="http://localhost:8899/solr/phaidra/schema/copyfields"
AUTH="phaidra:phaidra"

# All fields from managed-schema that should be copied to _text_ (excluding extracted_text)
FIELDS=(
  "_id"
  "_id._oid"
  "_root_"
  "_ts"
  "_updated"
  "_version_"
  "altformats"
  "altversions"
  "annotations"
  "annotations_json"
  "association"
  "association_id"
  "affiliation"
  "affiliation_id"
  "bbox"
  "bf_paralleltitle_maintitle"
  "bf_paralleltitle_subtitle"
  "bf_physicallocation"
  "bf_shelfmark"
  "bf_title_maintitle"
  "bf_title_subtitle"
  "checkafter"
  "cmodel"
  "created"
  "datastreams"
  "dc_license"
  "dcterms_accessrights_id"
  "dcterms_available"
  "dcterms_created_year"
  "dcterms_created_year_sort"
  "dcterms_datesubmitted"
  "dcterms_subject_id"
  "descriptions_json"
  "edm_hastype"
  "edm_hastype_id"
  "educational_context"
  "educational_enduserrole"
  "educational_learningresourcetype"
  "firstpagepid"
  "frapo_hasfundingagency_json"
  "frapo_isoutputof_json"
  "funder"
  "funder_id"
  "hasmember"
  "haspart"
  "hassuccessor"
  "hastrack"
  "id_bib_roles_pers_uploader"
  "isalternativeformatof"
  "isalternativeversionof"
  "isbacksideof"
  "isinadminset"
  "ismemberof"
  "ispartof"
  "isrestricted"
  "isthumbnailfor"
  "journal_title"
  "keyword_suggest"
  "language"
  "latlon"
  "members_metadata"
  "modified"
  "ns"
  "oaire_version_id"
  "object_type_id"
  "oer"
  "owl_sameas"
  "owner"
  "pid"
  "predecessor"
  "programme"
  "programme_id"
  "project"
  "project_id"
  "rdau_P60048"
  "rdau_P60048_id"
  "rdau_P60071_year"
  "rdau_P60071_year_sort"
  "references"
  "resourcetype"
  "roles_json"
  "schema_genre"
  "schema_genre_id"
  "schema_pageend"
  "schema_pagestart"
  "size"
  "sort_dc_title"
  "sort_deu_dc_title"
  "sort_eng_dc_title"
  "sort_ita_dc_title"
  "successor"
  "systemtag"
  "tcreated"
  "title_suggest"
  "title_suggest_ir"
  "tmodified"
  "tsize"
  "uwm_association_id"
  "uwm_funding"
  "uwm_roles_json"
  "vra_inscription"
)

echo "Adding copyFields to _text_ from managed-schema..."
echo "Total fields to add: ${#FIELDS[@]}"
echo ""

# Build JSON payload with all add-copy-field commands
JSON_PAYLOAD='{"add-copy-field": ['
for i in "${!FIELDS[@]}"; do
  if [ $i -gt 0 ]; then
    JSON_PAYLOAD+=','
  fi
  JSON_PAYLOAD+="{\"source\":\"${FIELDS[$i]}\",\"dest\":\"_text_\"}"
done
JSON_PAYLOAD+=']}'

# Send the request
echo "Sending request to Solr Schema API..."
RESPONSE=$(curl -s -u "$AUTH" -X POST "$SOLR_URL" \
  -H 'Content-Type: application/json' \
  -d "$JSON_PAYLOAD")

# Check response
if echo "$RESPONSE" | grep -q '"status":0'; then
  echo "✓ Successfully added all copyFields to _text_"
  echo ""
  echo "Verifying..."
  sleep 1
  COUNT=$(curl -s -u "$AUTH" "http://localhost:8899/solr/phaidra/schema/copyfields" | grep -c '"_text_"')
  echo "Found $COUNT copyFields copying to _text_"
  echo ""
  echo "Note: You'll need to reindex documents for _text_ to be updated."
else
  echo "✗ Error adding copyFields:"
  echo "$RESPONSE" | jq . 2>/dev/null || echo "$RESPONSE"
fi

