package phaidra.authz_test

import rego.v1

import data.phaidra.authz

test_change_owner_role_grants if {
	decision := authz.allow with input as {
		"subject": {
			"username": "owner-manager",
			"authenticated": true,
			"roles": ["canmodifyownerid"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {
			"type": "object",
			"pid": "o:1",
			"owner": "other-user",
			"state": "Active",
			"rights": {},
		},
		"action": {"id": "change_owner"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false},
	}
	decision.allow == true
}

test_change_owner_role_required if {
	decision := authz.allow with input as {
		"subject": {
			"username": "writer",
			"authenticated": true,
			"roles": ["writer"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {
			"type": "object",
			"pid": "o:1",
			"owner": "writer",
			"state": "Active",
			"rights": {},
		},
		"action": {"id": "change_owner"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false},
	}
	decision.allow == false
}
