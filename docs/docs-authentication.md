# Authorization
1. [Overview](#overview)
2. [Attributes](#attributes)

## Overview

PHAIDRA can be coupled with various mechanisms for authentication and the retrieval of user attributes and other information. Built in are:

* admin accounts - for Fedora, PHAIDRA and other services.

* LDAP + LAM (LDAP Account Manager - for defining local PHAIDRA accounts.

* Shibboleth - with affiliation filter to limit login to configured affiliations.

* Upstream authentication - special upstream authentication credentials can be configured which have the rights to set the remote user (all subsequent actions in the call are authorized in the name of the remote user). This is practical if the authentication is handled by the upstream system, but the authorization should still work against upstream usernames (which PHAIDRA API then have no way of authenticating).

Often the authentication is tailored for a particular institution, e.g. using institution's LDAP, or it's user database, a static configuration file, etc.

## Attributes

User attributes are useful to display basic information about owner accounts (name, email) as well as for authorization (affiliation, groups). Information about organisational structure is also helpful, i.e. for restricting object access to particular org units (if coupled with retrieving user's affiliation upon login) or for association of objects to units. How the attributes and the organigram are fetched (if they are fetched) varies from institution to institution. There is a Perl interface class which implements basic methods like

* authenticate (unless Shibboleth is used)
* get user data
* get organisation units (and subunits)
* get user's groups
* search users (used when defining access restrictions and in PHAIDRA's search to filter objects of a particular owner)
