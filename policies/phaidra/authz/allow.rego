package phaidra.authz

import rego.v1

import data.phaidra.authz.admin
import data.phaidra.authz.deny
import data.phaidra.authz.object as objectauthz
import data.phaidra.authz.rights
import data.phaidra.authz.datastream
import data.phaidra.authz.upload
import data.phaidra.authz.restrict
import data.phaidra.authz.space
import data.phaidra.authz.account
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
	input.action.id in {"read", "write", "delete", "restrict", "change_owner", "approve", "metadata_field"}
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
		"obligations": {"audit": false},
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
		"obligations": {"audit": false},
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
		"initial_state": upload.curated_state,
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
	input.action.id == "metadata_field"
	space.metadata_field_allowed(input.resource.metadata.field, input.resource.metadata.value)
	decision := {
		"allow": true,
		"effect": "allow",
		"reason": "metadata_field_allowed",
		"rights": "w",
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

allow := decision if {
	not deny.explicit
	is_object_action
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

allow := decision if {
	not deny.explicit
	not admin.grant
	not objectauthz.grant_rw
	helpers.is_read_op
	not datastream.is_private
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
