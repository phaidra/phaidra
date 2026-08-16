package phaidra.authz_test

import rego.v1

import data.phaidra.authz

test_admin_grants_rw if {
	decision := authz.allow with input as {
		"subject": {
			"username": "phaidraAdmin",
			"authenticated": true,
			"roles": ["admin"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {
			"type": "object",
			"pid": "o:1",
			"owner": "other",
			"state": "Active",
			"space": "default",
			"rights": {},
		},
		"action": {"id": "read", "operation": "r"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.rights == "rw"
	decision.reason == "admin"
}

test_owner_grants_rw if {
	decision := authz.allow with input as {
		"subject": {
			"username": "alice",
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
			"pid": "o:2",
			"owner": "alice",
			"state": "Active",
			"space": "default",
			"rights": {},
		},
		"action": {"id": "write", "operation": "w"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "owner"
}

test_anonymous_write_denied if {
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
		"resource": {
			"type": "object",
			"pid": "o:4",
			"owner": "alice",
			"state": "Active",
			"space": "default",
			"rights": {},
		},
		"action": {"id": "write", "operation": "w"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == false
	decision.reason == "deny_anonymous_write"
}

test_public_read_active_object if {
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
		"resource": {
			"type": "object",
			"pid": "o:5",
			"owner": "alice",
			"state": "Active",
			"space": "default",
			"rights": {},
		},
		"action": {"id": "read", "operation": "r"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.rights == "ro"
}

test_inactive_denied_for_reader if {
	decision := authz.allow with input as {
		"subject": {
			"username": "eve",
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
			"pid": "o:6",
			"owner": "alice",
			"state": "Inactive",
			"space": "default",
			"rights": {},
		},
		"action": {"id": "read", "operation": "r"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == false
	decision.reason == "deny_inactive_object"
}

test_rights_username_match if {
	decision := authz.allow with input as {
		"subject": {
			"username": "carol",
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
			"pid": "o:7",
			"owner": "alice",
			"state": "Active",
			"space": "default",
			"rights": {"username": ["carol"]},
		},
		"action": {"id": "read", "operation": "r"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "rights_match"
}

test_deprecated_rights_denied if {
	decision := authz.allow with input as {
		"subject": {
			"username": "carol",
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
			"pid": "o:8",
			"owner": "alice",
			"state": "Active",
			"space": "default",
			"rights": {"spl": ["x"]},
		},
		"action": {"id": "read", "operation": "r"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == false
	decision.reason == "deny_deprecated_rights_spl"
}

test_create_allowed_for_uploader if {
	decision := authz.allow with input as {
		"subject": {
			"username": "alice",
			"authenticated": true,
			"roles": ["uploader", "writer"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {
			"type": "object",
			"space": "default",
		},
		"action": {"id": "create", "operation": "w"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "uploader"
}
