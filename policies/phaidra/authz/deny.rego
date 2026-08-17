package phaidra.authz.deny

import rego.v1

import data.phaidra.authz.helpers
import data.phaidra.authz.metadata

explicit_reason := reason if {
	helpers.is_write_op
	not helpers.authenticated
	reason := "deny_anonymous_write"
}

explicit_reason := reason if {
	input.resource.rights.spl
	reason := "deny_deprecated_rights_spl"
}

explicit_reason := reason if {
	input.resource.rights.kennzahl
	reason := "deny_deprecated_rights_kennzahl"
}

explicit_reason := reason if {
	input.resource.rights.perfunk
	reason := "deny_deprecated_rights_perfunk"
}

explicit if {
	explicit_reason != ""
}

explicit_reason := reason if {
	helpers.authenticated
	metadata.deny_write
	reason := sprintf("deny_metadata_policy:%s", [metadata.matched_reason])
}
