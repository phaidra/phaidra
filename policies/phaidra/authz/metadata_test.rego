package phaidra.authz.metadata_test

import rego.v1

import data.phaidra.authz.metadata

oer_policy := {
	"id": "oer",
	"exempt_roles": ["approver", "admin"],
	"match": {"all": [
		{"field": "object_type", "ids": ["https://pid.phaidra.org/vocabulary/YA8R-1M0D"]},
		{"field": "object_type", "prefix": "https://w3id.org/kim/hcrt"},
		{"field": "license", "ids": ["http://creativecommons.org/licenses/by/4.0/"]},
	]},
}

thesis_policy := {
	"id": "thesis",
	"exempt_roles": ["librarian", "admin"],
	"match": {"all": [
		{"field": "object_type", "ids": ["https://pid.phaidra.org/vocabulary/62DN-RZ7V"]},
	]},
}

oer_metadata := {
	"object_type": [
		"https://pid.phaidra.org/vocabulary/YA8R-1M0D",
		"https://w3id.org/kim/hcrt/text",
	],
	"license": ["http://creativecommons.org/licenses/by/4.0/"],
}

plain_metadata := {
	"object_type": ["https://pid.phaidra.org/vocabulary/47QB-8QF1"],
	"license": [],
}

test_oer_needs_approval_on_create if {
	metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["uploader"]},
		"resource": {"type": "object", "metadata": oer_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as [oer_policy]
}

test_oer_no_approval_without_hcrt if {
	not metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["uploader"]},
		"resource": {"type": "object", "metadata": {
			"object_type": ["https://pid.phaidra.org/vocabulary/YA8R-1M0D"],
			"license": ["http://creativecommons.org/licenses/by/4.0/"],
		}},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as [oer_policy]
}

test_oer_approver_exempt_on_create if {
	not metadata.needs_approval with input as {
		"subject": {"username": "bob", "authenticated": true, "roles": ["approver", "uploader"]},
		"resource": {"type": "object", "metadata": oer_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as [oer_policy]
}

test_oer_deny_write_when_introducing_on_active if {
	metadata.deny_write with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["writer"]},
		"resource": {
			"type": "object",
			"state": "Active",
			"metadata": oer_metadata,
			"existing_metadata": plain_metadata,
		},
		"action": {"id": "write"},
	}
		with data.phaidra.config.metadata_policies as [oer_policy]
}

test_oer_write_allowed_when_already_set if {
	not metadata.deny_write with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["writer"]},
		"resource": {
			"type": "object",
			"state": "Active",
			"metadata": oer_metadata,
			"existing_metadata": oer_metadata,
		},
		"action": {"id": "write"},
	}
		with data.phaidra.config.metadata_policies as [oer_policy]
}

test_oer_inactive_write_queues_not_deny if {
	not metadata.deny_write with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["writer"]},
		"resource": {
			"type": "object",
			"state": "Inactive",
			"metadata": oer_metadata,
			"existing_metadata": plain_metadata,
		},
		"action": {"id": "write"},
	}
		with data.phaidra.config.metadata_policies as [oer_policy]

	metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["writer"]},
		"resource": {
			"type": "object",
			"state": "Inactive",
			"metadata": oer_metadata,
			"existing_metadata": plain_metadata,
		},
		"action": {"id": "write"},
	}
		with data.phaidra.config.metadata_policies as [oer_policy]
}

test_disabled_policy_ignored if {
	not metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["uploader"]},
		"resource": {"type": "object", "metadata": oer_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as [object.union(oer_policy, {"enabled": false})]
}

test_null_enabled_policy_ignored if {
	not metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["uploader"]},
		"resource": {"type": "object", "metadata": oer_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as [object.union(oer_policy, {"enabled": null})]
}

test_string_false_enabled_policy_ignored if {
	not metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["uploader"]},
		"resource": {"type": "object", "metadata": oer_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as [object.union(oer_policy, {"enabled": "false"})]
}

test_empty_policies_noop if {
	not metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["uploader"]},
		"resource": {"type": "object", "metadata": oer_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as []
}

test_create_curated_without_uploader if {
	metadata.needs_approval with input as {
		"subject": {"username": "alice", "authenticated": true, "roles": ["writer"]},
		"resource": {"type": "object", "metadata": plain_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as []
}

test_admin_create_uncurated_without_uploader if {
	not metadata.needs_approval with input as {
		"subject": {"username": "phaidraAdmin", "authenticated": true, "roles": ["admin", "writer"]},
		"resource": {"type": "object", "metadata": plain_metadata},
		"action": {"id": "create"},
	}
		with data.phaidra.config.metadata_policies as []
}

test_thesis_matches_object_type if {
	metadata.policy_matches({"object_type": ["https://pid.phaidra.org/vocabulary/62DN-RZ7V"]}, thesis_policy)
}
