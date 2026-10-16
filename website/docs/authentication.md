# Authentication

## Overview

PHAIDRA can be coupled with various mechanisms for authentication and the retrieval of user attributes and other information. Built in are:

* admin accounts - for Fedora, PHAIDRA and other services.

* LDAP + LAM (LDAP Account Manager - for defining local PHAIDRA accounts.

* Shibboleth - with affiliation filter to limit login to configured affiliations.

* Lightweight SCIM - a `/Users/<username>` call authenticated by JWT

Often the authentication is tailored for a particular institution, e.g. using institution's LDAP, or it's user database (via a small SCIM adapter), etc.

## Institutional repository login

When the public admin configuration contains `irbaseurl`, Shibboleth can return logins initiated by `phaidra-ir` to that IR. The IR starts authentication at `/login?client=ir&returnto=/path`; ordinary PHAIDRA logins without `client=ir` continue to return to `phaidra-ui`.

`irbaseurl` is the IR hostname, for example `scholar.example.edu`. PHAIDRA and the IR must use HTTPS sibling hosts under the same parent domain so the PHAIDRA `SameSite=Strict` session cookie is available to credentialed API requests. Return paths are restricted to local paths, and the callback origin is always derived from the server-side `irbaseurl` setting.

Local-account login remains available through the IR's direct `/nossologin` route.

## Attributes

User attributes are useful to display basic information about owner accounts (name, email) as well as for authorization (affiliation, groups). Information about organisational structure is also helpful, i.e. for restricting object access to particular org units (if coupled with retrieving user's affiliation upon login) or for association of objects to units. The organigramm is implemented as a static JSON in configuration.