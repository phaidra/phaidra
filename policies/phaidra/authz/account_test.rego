package phaidra.authz.account_test

import rego.v1

import data.phaidra.authz

test_settings_read_allowed_authenticated if {
	decision := authz.allow with input as {
		"subject": {
			"username": "alice",
			"authenticated": true,
			"roles": [],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {"type": "account"},
		"action": {"id": "settings_read"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "authenticated"
}

test_group_write_denied_anonymous if {
	decision := authz.allow with input as {
		"subject": {
			"username": "",
			"authenticated": false,
			"roles": [],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {"type": "account"},
		"action": {"id": "group_write"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == false
}
