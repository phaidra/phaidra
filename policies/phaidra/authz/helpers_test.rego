package phaidra.authz.helpers_test

import rego.v1

import data.phaidra.authz.helpers

test_role_granted_pep_role_defined_in_cfg if {
	helpers.role_granted("uploader") with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["uploader"]},
	}
}

test_role_granted_pep_role_undefined_in_cfg if {
	not helpers.role_granted("evil_role") with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["evil_role"]},
	}
}

test_role_granted_admin_not_via_cfg if {
	not helpers.role_granted("admin") with input as {
		"subject": {"username": "phaidraAdmin", "authenticated": true, "roles": ["admin"]},
	}
}

test_role_granted_via_cfg_all_authenticated if {
	helpers.role_granted("writer") with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": []},
	}
}
