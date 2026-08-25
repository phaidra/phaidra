package phaidra.authz.account

import rego.v1

import data.phaidra.authz.helpers

# Former $authenticated-only API actions (no Fedora object).
# Parity: any authenticated user. Tighten per action later via data bundles.
account_actions := {
	"settings_read",
	"settings_write",
	"group_read",
	"group_write",
	"list_read",
	"list_write",
	"template_read",
	"template_write",
	"stats_myobjects",
	"directory_self",
	"termsofuse_read",
	"termsofuse_agree",
	"users_search",
	"ir_allowsubmit",
	"ir_submit",
	"ir_notifications",
	"feedback",
	"request_doi",
}

is_account_action if {
	input.action.id in account_actions
}

can if {
	is_account_action
	helpers.authenticated
}
