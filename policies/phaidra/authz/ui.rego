package phaidra.authz.ui

import rego.v1

import data.phaidra.authz.helpers

form_allowed(form) if {
	not helpers.cfg.submit_forms[form]
}

form_allowed(form) if {
	roles := helpers.cfg.submit_forms[form].roles
	some role in roles
	role == "admin"
	data.phaidra.authz.admin.grant
}

form_allowed(form) if {
	roles := helpers.cfg.submit_forms[form].roles
	some role in roles
	helpers.role_granted(role)
}

capabilities contains cap if {
	form_allowed("catalogfetchupload")
	cap := "submit_form:catalogfetchupload"
}

capabilities contains cap if {
	form_allowed("bulkupload")
	cap := "submit_form:bulkupload"
}

skip_validation_allowed if {
	helpers.is_admin
}

skip_validation_allowed if {
	helpers.is_superuser
}

skip_validation_allowed if {
	helpers.role_granted("librarian")
}

skip_validation_allowed if {
	helpers.role_granted("power_user")
}

capabilities contains cap if {
	skip_validation_allowed
	cap := "submit:skip_validation"
}

capabilities contains cap if {
	data.phaidra.authz.upload.can_create
	cap := "create"
}

capabilities contains cap if {
	data.phaidra.authz.upload.can_approve
	cap := "approve"
}

capabilities contains cap if {
	helpers.is_admin
	cap := "admin"
}

capabilities contains cap if {
	data.phaidra.authz.inactive.can_manage
	cap := "inactive_objects_manage"
}
