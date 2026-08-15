package phaidra.authz.admin

import rego.v1

import data.phaidra.authz.helpers

grant if {
	helpers.is_admin
}

grant if {
	helpers.is_superuser
}
