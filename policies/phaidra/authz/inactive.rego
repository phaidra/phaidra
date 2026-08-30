package phaidra.authz.inactive

import rego.v1

import data.phaidra.authz.upload

# Staff (admin / curator-approver) can list all, register, and manage inactive rows.
# upload.can_approve already covers admin.grant and role_granted("approver").
can_manage if {
	upload.can_approve
}
