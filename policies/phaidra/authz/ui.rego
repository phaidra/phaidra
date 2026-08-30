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

capabilities contains cap if {
	data.phaidra.authz.upload.can_create
	cap := "create"
}

capabilities contains cap if {
	helpers.role_granted("writer")
	cap := "write"
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
