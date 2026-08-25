package phaidra.authz.rights

import rego.v1

import data.phaidra.authz.helpers

rights_defined if {
	count(object.keys(input.resource.rights)) > 0
}

rights_empty if {
	not rights_defined
}

rights_empty if {
	rights_defined
	not any_active_rule
}

any_active_rule if {
	some _ in input.resource.rights
}

matching_rule if {
	some rule in input.resource.rights.username
	helpers.rights_rule_active(rule)
	helpers.rights_value(rule) == input.subject.username
}

matching_rule if {
	some rule in input.resource.rights.affiliation
	helpers.rights_rule_active(rule)
	some aff in input.subject.affiliations
	helpers.rights_value(rule) == aff
}

matching_rule if {
	some rule in input.resource.rights.department
	helpers.rights_rule_active(rule)
	some dept in input.subject.org_units_l2
	helpers.rights_value(rule) == dept
}

matching_rule if {
	some rule in input.resource.rights.faculty
	helpers.rights_rule_active(rule)
	some fac in input.subject.org_units_l1
	helpers.rights_value(rule) == fac
}

matching_rule if {
	some rule in input.resource.rights.gruppe
	helpers.rights_rule_active(rule)
	some gid in input.subject.project_groups
	helpers.rights_value(rule) == gid
}

grant_read if {
	not rights_defined
}

grant_read if {
	rights_empty
}

grant_read if {
	matching_rule
}

deny_read if {
	rights_defined
	not rights_empty
	not matching_rule
}
