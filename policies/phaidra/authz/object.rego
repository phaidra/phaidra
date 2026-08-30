package phaidra.authz.object

import rego.v1

import data.phaidra.authz.helpers

grant_rw if {
	helpers.is_owner
}

# Approvers may edit metadata on objects awaiting activation / approval.
grant_rw if {
	helpers.role_granted("approver")
	input.resource.state in {"Inactive", "PendingApproval", "I"}
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

# Curators (approvers) need to preview/manage inactive objects in curated submit flows.
inactive_visible if {
	helpers.role_granted("approver")
}

deny_inactive_read if {
	helpers.is_read_op
	not inactive_visible
}
