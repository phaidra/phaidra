package phaidra.authz.object

import rego.v1

import data.phaidra.authz.helpers

grant_rw if {
	helpers.is_owner
}

inactive_visible if {
	input.resource.state == "Active"
}

inactive_visible if {
	helpers.is_owner
}

inactive_visible if {
	data.phaidra.authz.admin.grant
}

deny_inactive_read if {
	helpers.is_read_op
	not inactive_visible
}
