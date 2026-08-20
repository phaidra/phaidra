package phaidra.authz.upload

import rego.v1

import data.phaidra.authz.helpers

can_create if {
	data.phaidra.authz.admin.grant
}

can_create if {
	helpers.role_granted("uploader")
}

can_create if {
	helpers.role_granted("writer")
}

requires_writer_role if {
	helpers.is_write_op
	input.action.id != "delete"
	not data.phaidra.authz.admin.grant
	not data.phaidra.authz.object.grant_rw
	not helpers.role_granted("writer")
}

can_delete if {
	data.phaidra.authz.admin.grant
}

# Owner self-delete only when private config enabledelete is on (or require_enabledelete is off).
can_delete if {
	helpers.is_owner
	"owner" in helpers.cfg.delete.self_delete_roles
	not helpers.cfg.delete.require_enabledelete
}

can_delete if {
	helpers.is_owner
	"owner" in helpers.cfg.delete.self_delete_roles
	input.config.enabledelete == true
}

# Superuser self-delete follows the same enabledelete gate (admin.grant still bypasses).
can_delete if {
	helpers.has_role("superuser")
	"superuser" in helpers.cfg.delete.self_delete_roles
	not helpers.cfg.delete.require_enabledelete
}

can_delete if {
	helpers.has_role("superuser")
	"superuser" in helpers.cfg.delete.self_delete_roles
	input.config.enabledelete == true
}

can_change_owner if {
	data.phaidra.authz.admin.grant
}

can_change_owner if {
	some user in input.config.canmodifyownerid
	user == input.subject.username
}

can_approve if {
	helpers.role_granted("approver")
}

can_approve if {
	data.phaidra.authz.admin.grant
}
