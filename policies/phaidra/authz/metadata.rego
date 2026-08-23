package phaidra.authz.metadata

import rego.v1

import data.phaidra.authz.helpers

# Curation on create:
# - Uncurated submit requires the uploader role (or admin).
# - Instance-wide on  = nobody is granted uploader (default_role unset).
# - Instance-wide off = default_role=uploader, empty metadata_policies.
# - Conditional       = default_role=uploader + metadata_policies (queue on introducing).
#
# Metadata policies fire on *introducing* a match (proposed matches, existing does not).
# Repeating already-stored values (full JSON-LD POST that only changes title) is not a match.
enabled_policies contains p if {
	some p in object.get(helpers.cfg, "metadata_policies", [])
	object.get(p, "enabled", true) == true
}

proposed := object.get(input.resource, "metadata", {})

existing := object.get(input.resource, "existing_metadata", {})

is_active if {
	input.resource.state == "Active"
}

values_for(md, field) := object.get(md, field, [])

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

clause_matches(md, clause) if {
	some v in values_for(md, clause.field)
	ids_match(clause, v)
	prefix_match(clause, v)
}

all_clauses_match(md, p) if {
	clauses := object.get(object.get(p, "match", {}), "all", [])
	count(clauses) > 0
	every clause in clauses {
		clause_matches(md, clause)
	}
}

policy_matches(md, p) if {
	all_clauses_match(md, p)
}

exempt(p) if {
	some role in object.get(p, "exempt_roles", [])
	helpers.role_granted(role)
}

exempt(p) if {
	"admin" in object.get(p, "exempt_roles", [])
	data.phaidra.authz.admin.grant
}

# Proposed payload newly satisfies a policy that the stored object did not.
introducing_ids contains p.id if {
	some p in enabled_policies
	policy_matches(proposed, p)
	not policy_matches(existing, p)
	not exempt(p)
}

can_uncurated_submit if {
	helpers.role_granted("uploader")
}

can_uncurated_submit if {
	data.phaidra.authz.admin.grant
}

# No uploader role ⇒ every create is curated (instance-wide on).
needs_approval if {
	input.action.id == "create"
	not can_uncurated_submit
}

needs_approval if {
	input.action.id == "create"
	count(introducing_ids) > 0
}

needs_approval if {
	input.action.id == "write"
	not is_active
	count(introducing_ids) > 0
}

deny_write if {
	input.action.id == "write"
	is_active
	count(introducing_ids) > 0
}

matched_reason := concat(",", sort(introducing_ids))
