package phaidra.authz.siteadmin

import rego.v1

import data.phaidra.authz.helpers

# Former $admin bridge endpoints (site admin username from config).
admin_actions := {
	"admin_storage_usage",
	"admin_storage_avg_year",
	"admin_imageserver_storage_avg_year",
	"admin_send_daily_report",
	"admin_config_private_read",
	"admin_config_public_write",
	"admin_config_private_write",
	"admin_oai_blacklist",
	"admin_index",
	"admin_object_index",
	"admin_imageserver_process",
	"admin_tikaserver_process",
	"admin_streaming_process",
	"admin_objects_modify_bulk",
	"admin_objects_delete_bulk",
	"admin_templates_read",
	"admin_templates_write",
	"admin_ir_embargocheck",
}

# Former $ir_admin bridge endpoints.
ir_admin_actions := {
	"ir_admin_listdata",
	"ir_admin_events",
	"ir_admin_puresearch",
	"ir_admin_pureimport_locks",
	"ir_admin_accept",
	"ir_admin_reject",
	"ir_admin_approve",
	"ir_admin_pureimport_lock",
	"ir_admin_pureimport_unlock",
	"ir_admin_pureimport_reject",
}

# Match legacy authenticate_admin: configured phaidra admin username.
is_site_admin if {
	input.subject.username == input.config.admin_username
	input.config.admin_username != ""
}

is_ir_admin if {
	"ir_admin" in input.subject.roles
}

can_admin if {
	input.action.id in admin_actions
	is_site_admin
}

can_ir_admin if {
	input.action.id in ir_admin_actions
	is_ir_admin
}
