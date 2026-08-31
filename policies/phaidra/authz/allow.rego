package phaidra.authz

import rego.v1

import data.phaidra.authz.admin
import data.phaidra.authz.deny
import data.phaidra.authz.object as objectauthz
import data.phaidra.authz.rights
import data.phaidra.authz.datastream
import data.phaidra.authz.upload
import data.phaidra.authz.restrict
import data.phaidra.authz.metadata
import data.phaidra.authz.account
import data.phaidra.authz.inactive
import data.phaidra.authz.siteadmin
import data.phaidra.authz.helpers

default allow := {
	"allow": false,
	"effect": "deny",
	"reason": "default_deny",
	"rights": "",
	"obligations": {"audit": true},
}

is_object_action if {
	input.action.id in {"read", "write", "delete", "restrict", "change_owner", "approve"}
}

allow := decision if {
	reason := deny.explicit_reason
	decision := {
		"allow": false,
		"effect": "deny",
		"reason": reason,
		"rights": "",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	input.action.id == "capabilities"
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "capabilities",
		"rights": "",
		"capabilities": data.phaidra.authz.ui.capabilities,
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	input.action.id == "check_forms"
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "form_check",
		"rights": "",
		"forms": {form: data.phaidra.authz.ui.form_allowed(form) |
			some form in object.keys(data.phaidra.config.submit_forms)
		},
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	input.action.id == "create"
	upload.can_create
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "uploader",
		"rights": "rw",
		"initial_state": create_initial_state,
		"matched_policy": metadata.matched_reason,
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	account.can
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "authenticated",
		"rights": "",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	input.action.id == "inactive_objects_manage"
	inactive.can_manage
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "inactive_objects_manage",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	siteadmin.can_admin
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "site_admin",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	siteadmin.can_ir_admin
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "ir_admin",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	input.action.id == "delete"
	upload.can_delete
	objectauthz.grant_rw
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "delete_allowed",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	input.action.id == "change_owner"
	upload.can_change_owner
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "change_owner",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	input.action.id == "approve"
	upload.can_approve
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "approver",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	input.action.id == "restrict"
	restrict.can_modify_restrictions
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "restrict_allowed",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	is_object_action
	admin.grant
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "admin",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

# Owner rw for read/write. delete / restrict / change_owner / approve have dedicated rules
# (overlapping complete rules cause OPA eval_conflict → fail-closed deny).
allow := decision if {
	not deny.explicit
	input.action.id in {"read", "write"}
	not admin.grant
	objectauthz.grant_rw
	helpers.is_owner
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "owner",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

# Approver write on inactive / pending (grant_rw without ownership).
allow := decision if {
	not deny.explicit
	not admin.grant
	input.action.id == "write"
	objectauthz.grant_rw
	not helpers.is_owner
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "staff_inactive_write",
		"rights": "rw",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	datastream.deny_private_read
	decision := {
		"allow": false,
		"effect": "deny",
		"reason": "deny_private_datastream",
		"rights": "",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	datastream.deny_inactive_metadata
	decision := {
		"allow": false,
		"effect": "deny",
		"reason": "deny_inactive_metadata",
		"rights": "",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	helpers.is_write_op
	input.action.id == "write"
	decision := {
		"allow": false,
		"effect": "deny",
		"reason": "deny_no_write_permission",
		"rights": "",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	helpers.is_read_op
	not datastream.is_private
	datastream.rights_gated
	rights.deny_read
	not objectauthz.deny_inactive_read
	decision := {
		"allow": false,
		"effect": "deny",
		"reason": "deny_no_matching_rule",
		"rights": "",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	objectauthz.deny_inactive_read
	decision := {
		"allow": false,
		"effect": "deny",
		"reason": "deny_inactive_object",
		"rights": "",
		"obligations": {"audit": true},
	}
}

# Public metadata (JSON-LD, MODS, …): Active objects are readable regardless of RIGHTS.
allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	helpers.is_read_op
	not datastream.is_private
	datastream.metadata_public
	not objectauthz.deny_inactive_read
	not datastream.deny_inactive_metadata
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "public_metadata",
		"rights": "ro",
		"obligations": {"audit": true},
	}
}

allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	helpers.is_read_op
	not datastream.is_private
	datastream.rights_gated
	rights.grant_read
	not objectauthz.deny_inactive_read
	read_reason != ""
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": read_reason,
		"rights": "ro",
		"obligations": {"audit": true},
	}
}

read_reason := "rights_match" if {
	rights.matching_rule
}

read_reason := "no_rules_defined" if {
	rights.rights_defined
	rights.rights_empty
	not rights.matching_rule
}

read_reason := "no_rights_datastream" if {
	not rights.rights_defined
}

create_initial_state := "PendingApproval" if {
	metadata.needs_approval
}

create_initial_state := "Inactive" if {
	not metadata.needs_approval
}
