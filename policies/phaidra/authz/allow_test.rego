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
			"rights": {},
		},
		"action": {"id": "read"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.rights == "rw"
	decision.reason == "admin"
}

# Admin who also owns the object must not produce two complete `allow` outputs.
test_admin_owner_read_no_conflict if {
	decision := authz.allow with input as {
		"subject": {
			"username": "phaidraAdmin",
			"authenticated": true,
			"roles": ["admin", "writer", "uploader", "ir_admin"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {
			"type": "object",
			"pid": "o:48",
			"owner": "phaidraAdmin",
			"state": "Active",
			"rights": {},
		},
		"action": {"id": "read"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": ["username1"]},
	}
	decision.allow == true
	decision.reason == "admin"
	decision.rights == "rw"
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
			"rights": {},
		},
		"action": {"id": "write"},
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
			"rights": {},
		},
		"action": {"id": "write"},
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
			"rights": {},
		},
		"action": {"id": "read"},
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
			"rights": {},
		},
		"action": {"id": "read"},
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
			"rights": {"username": ["carol"]},
		},
		"action": {"id": "read"},
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
			"rights": {"spl": ["x"]},
		},
		"action": {"id": "read"},
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
		},
		"action": {"id": "create"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "uploader"
	decision.initial_state == "Inactive"
}

test_create_queued_without_uploader if {
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
		},
		"action": {"id": "create"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.initial_state == "PendingApproval"
}

test_admin_create_not_queued if {
	decision := authz.allow with input as {
		"subject": {
			"username": "phaidraAdmin",
			"authenticated": true,
			"roles": ["admin", "writer"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {
			"type": "object",
		},
		"action": {"id": "create"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.initial_state == "Inactive"
}

test_private_ds_denied_anonymous if {
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
			"pid": "o:10",
			"owner": "alice",
			"state": "Active",
			"dsid": "RIGHTS",
			"rights": {},
		},
		"action": {"id": "read"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == false
	decision.reason == "deny_private_datastream"
}

test_private_ds_allowed_for_owner if {
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
			"pid": "o:10",
			"owner": "alice",
			"state": "Active",
			"dsid": "JSON-LD-PRIVATE",
			"rights": {},
		},
		"action": {"id": "read"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "owner"
}

test_site_admin_config_read if {
	decision := authz.allow with input as {
		"subject": {
			"username": "phaidraAdmin",
			"authenticated": true,
			"roles": ["admin", "writer", "uploader"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {"type": "admin"},
		"action": {"id": "admin_config_private_read"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "site_admin"
}

test_site_admin_denied_for_non_admin if {
	decision := authz.allow with input as {
		"subject": {
			"username": "alice",
			"authenticated": true,
			"roles": ["writer", "uploader"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {"type": "admin"},
		"action": {"id": "admin_index"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == false
}

test_ir_admin_accept if {
	decision := authz.allow with input as {
		"subject": {
			"username": "iruser",
			"authenticated": true,
			"roles": ["ir_admin", "writer", "uploader"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {"type": "admin"},
		"action": {"id": "ir_admin_accept"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == true
	decision.reason == "ir_admin"
}

test_ir_admin_denied_without_role if {
	decision := authz.allow with input as {
		"subject": {
			"username": "alice",
			"authenticated": true,
			"roles": ["writer", "uploader"],
			"affiliations": [],
			"org_units_l1": [],
			"org_units_l2": [],
			"ldap_groups": [],
			"project_groups": [],
		},
		"resource": {"type": "admin"},
		"action": {"id": "ir_admin_accept"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
	decision.allow == false
}

oer_policies := [{
	"id": "oer",
	"exempt_roles": ["approver", "admin"],
	"match": {"all": [
		{"field": "object_type", "ids": ["https://pid.phaidra.org/vocabulary/YA8R-1M0D"]},
		{"field": "object_type", "prefix": "https://w3id.org/kim/hcrt"},
		{"field": "license", "ids": ["http://creativecommons.org/licenses/by/4.0/"]},
	]},
}]

oer_md := {
	"object_type": [
		"https://pid.phaidra.org/vocabulary/YA8R-1M0D",
		"https://w3id.org/kim/hcrt/text",
	],
	"license": ["http://creativecommons.org/licenses/by/4.0/"],
}

test_oer_create_pending_approval if {
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
		"resource": {"type": "object", "metadata": oer_md},
		"action": {"id": "create"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
		with data.phaidra.config.metadata_policies as oer_policies
	decision.allow == true
	decision.initial_state == "PendingApproval"
}

test_oer_write_denied if {
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
			"pid": "o:9",
			"owner": "alice",
			"state": "Active",
			"rights": {},
			"metadata": oer_md,
			"existing_metadata": {"object_type": [], "license": []},
		},
		"action": {"id": "write"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
		with data.phaidra.config.metadata_policies as oer_policies
	decision.allow == false
	decision.reason == "deny_metadata_policy:oer"
}

test_oer_write_allowed_when_already_oer if {
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
			"pid": "o:9",
			"owner": "alice",
			"state": "Active",
			"rights": {},
			"metadata": oer_md,
			"existing_metadata": oer_md,
		},
		"action": {"id": "write"},
		"environment": {"institution": "default"},
		"config": {"admin_username": "phaidraAdmin", "enabledelete": false, "canmodifyownerid": []},
	}
		with data.phaidra.config.metadata_policies as oer_policies
	decision.allow == true
	decision.reason == "owner"
}

