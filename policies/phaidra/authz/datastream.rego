package phaidra.authz.datastream

import rego.v1

import data.phaidra.authz.helpers

private_datastreams := {"RIGHTS", "JSON-LD-PRIVATE"}

restricted_content_datastreams := {"OCTETS", "FULLTEXT", "WEBVERSION"}

is_private if {
	input.resource.dsid in private_datastreams
}

requires_object_read if {
	input.resource.dsid in restricted_content_datastreams
}

requires_object_read if {
	input.resource.dsid != ""
	not input.resource.dsid in private_datastreams
	helpers.is_read_op
}

metadata_public if {
	input.resource.dsid in {"JSON-LD", "UWMETADATA", "MODS", "ANNOTATIONS", "GEO", "DC"}
}

metadata_public if {
	input.action.endpoint in {
		"object#get_metadata",
		"object#get_uwmetadata",
		"object#get_mods",
		"object#get_jsonld",
	}
}

deny_private_read if {
	is_private
	not helpers.is_write_op
	not data.phaidra.authz.admin.grant
	not data.phaidra.authz.object.grant_rw
}

deny_inactive_metadata if {
	metadata_public
	input.resource.state != "Active"
	not data.phaidra.authz.object.inactive_visible
}
