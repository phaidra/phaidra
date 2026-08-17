package phaidra.authz.metadata

import rego.v1

import data.phaidra.authz.helpers

# Institution-optional rules in data.phaidra.config.metadata_policies.
# Empty / omitted ⇒ no extra submit or edit constraints.
enabled_policies contains p if {
	some p in object.get(helpers.cfg, "metadata_policies", [])
	not p.enabled == false
}

values_for(field) := object.get(input.resource.metadata, field, [])

ids_match(clause, value) if {
	ids := object.get(clause, "ids", [])
	count(ids) == 0
}

ids_match(clause, value) if {
	value in object.get(clause, "ids", [])
}

prefix_match(clause, value) if {
	object.get(clause, "prefix", "") == ""
}

prefix_match(clause, value) if {
	prefix := object.get(clause, "prefix", "")
	prefix != ""
	startswith(value, prefix)
}

clause_matches(clause) if {
	some v in values_for(clause.field)
	ids_match(clause, v)
	prefix_match(clause, v)
}

all_clauses_match(p) if {
	clauses := object.get(object.get(p, "match", {}), "all", [])
	count(clauses) > 0
	every clause in clauses {
		clause_matches(clause)
	}
}

policy_matches(p) if {
	all_clauses_match(p)
}

exempt(p) if {
	some role in object.get(p, "exempt_roles", [])
	helpers.role_granted(role)
}

exempt(p) if {
	"admin" in object.get(p, "exempt_roles", [])
	data.phaidra.authz.admin.grant
}

matched_policy_ids contains p.id if {
	some p in enabled_policies
	policy_matches(p)
	not exempt(p)
}

needs_approval if {
	input.action.id == "create"
	count(matched_policy_ids) > 0
}

deny_write if {
	input.action.id == "write"
	count(matched_policy_ids) > 0
}

matched_reason := concat(",", sort(matched_policy_ids))
