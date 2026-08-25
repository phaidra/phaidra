# Authentication

## Overview

PHAIDRA can be coupled with various mechanisms for authentication and the retrieval of user attributes and other information. Built in are:

* admin accounts - for Fedora, PHAIDRA and other services.

* LDAP + LAM (LDAP Account Manager - for defining local PHAIDRA accounts.

* Shibboleth - with affiliation filter to limit login to configured affiliations.

* Lightweight SCIM - a `/Users/<username>` call authenticated by JWT

Often the authentication is tailored for a particular institution, e.g. using institution's LDAP, or it's user database (via a small SCIM adapter), etc.

## Attributes

User attributes are useful to display basic information about owner accounts (name, email) as well as for authorization (affiliation, groups). Information about organisational structure is also helpful, i.e. for restricting object access to particular org units (if coupled with retrieving user's affiliation upon login) or for association of objects to units. The organigramm is implemented as a static JSON in configuration.