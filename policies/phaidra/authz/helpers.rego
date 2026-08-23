package phaidra.authz.helpers

import rego.v1

cfg := data.phaidra.config

is_write_op if {
	input.action.id in {
		"write",
		"create",
		"delete",
		"approve",
		"restrict",
		"change_owner",
	}
}

is_read_op if {
	input.action.id == "read"
}

authenticated if {
	input.subject.authenticated == true
	input.subject.username != ""
}

is_admin if {
	input.config.admin_username != ""
	input.subject.username == input.config.admin_username
}

is_admin if {
	cfg.admin_username != ""
	input.subject.username == cfg.admin_username
}

is_admin if {
	"admin" in input.subject.roles
}

is_superuser if {
	"superuser" in input.subject.roles
}

has_role(role) if {
	role in input.subject.roles
}

role_granted(role) if {
	role in input.subject.roles
}

role_granted(role) if {
	role_cfg := cfg.roles[role]
	role_cfg.all_authenticated == true
	authenticated
}

role_granted(role) if {
	role_cfg := cfg.roles[role]
	some username in role_cfg.usernames
	username == input.subject.username
}

role_granted(role) if {
	role_cfg := cfg.roles[role]
	some affiliation in role_cfg.affiliations
	affiliation in input.subject.affiliations
}

role_granted(role) if {
	role_cfg := cfg.roles[role]
	some ldap_group in role_cfg.ldap_groups
	ldap_group in input.subject.ldap_groups
}

is_owner if {
	input.resource.owner == input.subject.username
}

rights_value(rule) := value if {
	is_string(rule)
	value := rule
}

rights_value(rule) := value if {
	is_object(rule)
	value := rule.value
}

rights_expired(rule) if {
	is_object(rule)
	rule.expires != null
	rule.expires != ""
	time.now_ns() > time.parse_rfc3339_ns(rule.expires)
}

rights_rule_active(rule) if {
	not rights_expired(rule)
}

