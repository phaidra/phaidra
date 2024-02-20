# Authentication

## Overview

PHAIDRA can be coupled with various mechanisms for authentication and the retrieval of user attributes and other information. Built in are:

* admin accounts - for Fedora, PHAIDRA and other services.

* LDAP + LAM (LDAP Account Manager - for defining local PHAIDRA accounts.

* Shibboleth - with affiliation filter to limit login to configured affiliations.

* Upstream authentication - special upstream authentication credentials can be configured which have the rights to set the remote user (all subsequent actions in the call are authorized in the name of the remote user). This is practical if the authentication is handled by the upstream system, but the authorization should still work against upstream usernames (which PHAIDRA API then have no way of authenticating).

Often the authentication is tailored for a particular institution, e.g. using institution's LDAP, or it's user database, a static configuration file, etc.

## Attributes

User attributes are useful to display basic information about owner accounts (name, email) as well as for authorization (affiliation, groups). Information about organisational structure is also helpful, i.e. for restricting object access to particular org units (if coupled with retrieving user's affiliation upon login) or for association of objects to units. How the attributes and the organigram are fetched (if they are fetched) varies from institution to institution. There interface to these methods is a Perl class (inherited from Phaidra::Directory) which should implement following methods

* authenticate - unless Shibboleth is used.
* get_user_data - gets firstname, lastname, email and affiliation.
* search_user - used when defining access restrictions and in PHAIDRA's search to filter objects of a particular owner.
* org_get_units
* org_get_subunits
* org_get_superunits
* org_get_parentpath
* get_users_groups
* get_group
* create_group
* delete_group
* remove_group_member
* add_group_member

Once a class have been implemented and put to the `phaidra/src/phaidra-api/lib/phaidra_directory/Phaidra/Directory/` folder, it needs to be configured in PhaidraAPI.json in following stanza
```
"directory_class": "Phaidra::Directory::TheImplementationClass",
```
e.g.
```
"directory_class": "Phaidra::Directory::GenericLDAP",
```

An example of the implementation of this class is <a href="https://github.com/phaidra/phaidra/blob/main/src/phaidra-api/lib/phaidra_directory/Phaidra/Directory/GenericLDAP.pm" target="_blank">GenericLDAP.pm</a> which is used in the demo version.
