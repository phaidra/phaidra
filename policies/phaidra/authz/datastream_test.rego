package phaidra.authz.datastream_test

import rego.v1

import data.phaidra.authz.datastream

test_rights_is_private if {
	datastream.is_private with input as {"resource": {"dsid": "RIGHTS"}}
}

test_jsonld_private_is_private if {
	datastream.is_private with input as {"resource": {"dsid": "JSON-LD-PRIVATE"}}
}

test_octets_not_private if {
	not datastream.is_private with input as {"resource": {"dsid": "OCTETS"}}
}

test_empty_dsid_not_private if {
	not datastream.is_private with input as {"resource": {"dsid": ""}}
}
