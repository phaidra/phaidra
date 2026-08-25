package phaidra.authz.datastream

import rego.v1

import data.phaidra.authz.helpers

# Owner/admin only (never public, even when Active).
private_datastreams := {"RIGHTS", "JSON-LD-PRIVATE"}

# RIGHTS ACL applies to binary/content access (and thumbnail/preview).
restricted_content_datastreams := {"OCTETS", "FULLTEXT", "WEBVERSION"}

# Public metadata — readable for Active objects regardless of RIGHTS.
public_metadata_datastreams := {
	"JSON-LD",
	"UWMETADATA",
	"MODS",
	"ANNOTATIONS",
	"GEO",
	"DC",
}

content_endpoints := {
	"object#preview",
	"object#thumbnail",
	"object#get_legacy_container_member",
	"object#get_resourcelink",
	"object#redirect_resourcelink",
	"octets#get",
	"octets#download",
	"octets#proxy",
	"fulltext#get",
	"streaming#key",
	"threed#get_resource",
	"viewer360#get_frame",
	"viewer360#get_frame_by_name",
	"imageserver#status",
}

metadata_endpoints := {
	"jsonld#get",
	"uwmetadata#get",
	"mods#get",
	"geo#get",
	"annotations#get",
	"object#get_metadata",
}

default is_private := false

is_private if {
	input.resource.dsid in private_datastreams
}

metadata_public if {
	input.resource.dsid in public_metadata_datastreams
}

metadata_public if {
	input.action.endpoint in metadata_endpoints
}

# RIGHTS gates content/thumbnail — not public metadata, not private dsids.
rights_gated if {
	helpers.is_read_op
	not is_private
	not metadata_public
	input.resource.dsid in restricted_content_datastreams
}

rights_gated if {
	helpers.is_read_op
	not is_private
	not metadata_public
	input.action.endpoint in content_endpoints
}

# Generic object read (no endpoint/dsid), e.g. /authz/check — treat as content ACL.
rights_gated if {
	helpers.is_read_op
	not is_private
	not metadata_public
	object.get(input.resource, "dsid", "") == ""
	object.get(input.action, "endpoint", "") == ""
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
