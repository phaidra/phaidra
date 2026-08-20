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

test_jsonld_endpoint_is_public_metadata if {
	datastream.metadata_public with input as {
		"resource": {"dsid": ""},
		"action": {"id": "read", "endpoint": "jsonld#get"},
	}
}

test_preview_is_rights_gated if {
	datastream.rights_gated with input as {
		"resource": {"dsid": ""},
		"action": {"id": "read", "endpoint": "object#preview"},
		"subject": {"authenticated": false, "roles": []},
	}
}

test_jsonld_not_rights_gated if {
	not datastream.rights_gated with input as {
		"resource": {"dsid": ""},
		"action": {"id": "read", "endpoint": "jsonld#get"},
		"subject": {"authenticated": false, "roles": []},
	}
}
