package phaidra.authz.space

import rego.v1

import data.phaidra.authz.helpers

metadata_field_allowed(field, value) if {
	not helpers.cfg.metadata[field]
}

metadata_field_allowed(field, value) if {
	not helpers.cfg.metadata[field][value]
}

metadata_field_allowed(field, value) if {
	allowed := helpers.cfg.metadata[field][value]
	some role in allowed.roles
	helpers.role_granted(role)
}

metadata_field_allowed(field, value) if {
	allowed := helpers.cfg.metadata[field][value]
	"admin" in allowed.roles
	data.phaidra.authz.admin.grant
}
