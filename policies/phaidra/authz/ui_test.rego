package phaidra.authz.ui_test

import rego.v1

import data.phaidra.authz.ui

role_config := {
	"roles": {
		"librarian": {},
		"power_user": {},
	},
	"submit_forms": {},
}

test_librarian_can_skip_validation if {
	"submit:skip_validation" in ui.capabilities with input as {
		"subject": {"username": "librarian", "authenticated": true, "roles": ["librarian"]},
	} with data.phaidra.config as role_config
}

test_power_user_can_skip_validation if {
	"submit:skip_validation" in ui.capabilities with input as {
		"subject": {"username": "power-user", "authenticated": true, "roles": ["power_user"]},
	} with data.phaidra.config as role_config
}

test_admin_can_skip_validation if {
	"submit:skip_validation" in ui.capabilities with input as {
		"subject": {"username": "admin", "authenticated": true, "roles": ["admin"]},
	} with data.phaidra.config as role_config
}

test_superuser_can_skip_validation if {
	"submit:skip_validation" in ui.capabilities with input as {
		"subject": {"username": "superuser", "authenticated": true, "roles": ["superuser"]},
	} with data.phaidra.config as role_config
}

test_regular_user_cannot_skip_validation if {
	not "submit:skip_validation" in ui.capabilities with input as {
		"subject": {"username": "user", "authenticated": true, "roles": []},
	} with data.phaidra.config as role_config
}
