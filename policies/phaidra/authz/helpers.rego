package phaidra.authz.helpers

import rego.v1

cfg := data.phaidra.config

is_write_op if {
	input.action.operation in {"w", "rw"}
}

is_read_op if {
	input.action.operation in {"r", "ro"}
}

action_id := input.action.id

authenticated if {
	input.subject.authenticated == true
	input.subject.username != ""
}

is_admin if {
	input.subject.username == input.config.admin_username
}

is_admin if {
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

group_owner_id := gid if {
	startswith(input.resource.owner, cfg.project_groups.owner_prefix)
	gid := trim_prefix(input.resource.owner, cfg.project_groups.owner_prefix)
}

is_virtual_group_owner if {
	cfg.project_groups.enabled == true
	gid := group_owner_id
	gid in input.subject.project_groups
}

is_virtual_group_owner if {
	not cfg.project_groups
	startswith(input.resource.owner, "group:")
	gid := trim_prefix(input.resource.owner, "group:")
	gid in input.subject.project_groups
}

is_owner_or_group_owner if {
	is_owner
}

is_owner_or_group_owner if {
	is_virtual_group_owner
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

space_cfg := cfg.spaces[input.resource.space]

space_cfg := cfg.spaces.default if {
	not cfg.spaces[input.resource.space]
}
