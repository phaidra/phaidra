package phaidra.authz.metadata

import rego.v1

import data.phaidra.authz.helpers

# Create state follows the highest upload role:
# - unrestricted_uploader and site admin create Active objects.
# - uploader creates Active objects unless an introducing metadata policy queues it.
# - curated_uploader creates PendingApproval objects.
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

# Missing ids key: prefix-only clause (no id filter). Explicit ids (including []) use list match.
ids_match(clause, value) if {
	object.get(clause, "ids", null) == null
}

ids_match(clause, value) if {
	ids := clause.ids
	count(ids) > 0
	value in ids
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

can_bypass_curation if {
	helpers.role_granted("unrestricted_uploader")
}

can_bypass_curation if {
	data.phaidra.authz.admin.grant
}

has_uploader if {
	helpers.role_granted("uploader")
}

has_curated_uploader if {
	helpers.role_granted("curated_uploader")
}

# Role precedence is unrestricted_uploader, uploader, then curated_uploader.
needs_approval if {
	input.action.id == "create"
	not can_bypass_curation
	has_uploader
	count(introducing_ids) > 0
}

needs_approval if {
	input.action.id == "create"
	not can_bypass_curation
	not has_uploader
	has_curated_uploader
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
