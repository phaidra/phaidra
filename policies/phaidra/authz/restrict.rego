package phaidra.authz.restrict

import rego.v1

import data.phaidra.authz.helpers

can_modify_restrictions if {
	data.phaidra.authz.admin.grant
}

can_modify_restrictions if {
	helpers.is_owner
	some role in helpers.cfg.restrictions.allowed_roles
	role == "owner"
}

can_modify_restrictions if {
	helpers.is_superuser
	some role in helpers.cfg.restrictions.allowed_roles
	role == "superuser"
}
