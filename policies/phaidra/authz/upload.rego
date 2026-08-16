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

can_delete if {
	helpers.has_role("superuser")
	"superuser" in helpers.cfg.delete.self_delete_roles
}

can_change_owner if {
	data.phaidra.authz.admin.grant
}

can_change_owner if {
	some user in input.config.canmodifyownerid
	user == input.subject.username
}

curated_state := "PendingApproval" if {
	helpers.space_cfg.curated_submit == true
	not direct_upload_allowed
}

curated_state := "Inactive" if {
	not helpers.space_cfg.curated_submit
}

curated_state := "Inactive" if {
	direct_upload_allowed
}

direct_upload_allowed if {
	some role in helpers.space_cfg.direct_upload_roles
	helpers.role_granted(role)
}

direct_upload_allowed if {
	data.phaidra.authz.admin.grant
}

can_approve if {
	helpers.role_granted("approver")
}

can_approve if {
	data.phaidra.authz.admin.grant
}
