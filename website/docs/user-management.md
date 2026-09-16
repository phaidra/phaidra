# User management

PHAIDRA supports database-backed users in addition to Shibboleth authentication. Database users are stored in MariaDB and can be managed by an administrator. This makes it possible to provide accounts for users that are not represented by the institutional directory without replacing existing identity-provider integrations.

## Identity sources and precedence

PHAIDRA looks up user data in the database before consulting remote identity sources. A database record can therefore supplement or override externally supplied data for the same username.

A user with a password is a **local account** and can authenticate through the login page or HTTP Basic authentication. A database user without a password is a **remote account**: it cannot use local-password login, but can retain attributes and administrator-controlled access settings while authenticating through Shibboleth.

Shibboleth remains available for users without a database record. Adding database users therefore does not require migrating existing remote identities.

## User data

A database user has the following attributes:

- immutable username;
- first name, last name, display name, and email address;
- affiliations, for example Shibboleth affiliations;
- organization units, selected from the configured organization-unit vocabulary;
- roles;
- active or blocked status;
- optional expiry date;
- last-login time; and
- creation and update timestamps.

A blocked account or an expired account cannot authenticate. For remote users, the database record is also an administrator-controlled override: blocking or expiring it prevents access even when the external identity provider accepts the user.

## Roles and authorization

Roles are strings assigned to users. The available role names come from the OPA authorization data, together with the built-in `admin` and `superuser` roles. Their meaning is defined by the authorization policy and institution configuration, rather than by the user tables.

The configured default role is applied to remote authenticated sessions and is also stored when a remote user is first provisioned. Later stored-role changes are administrator-controlled and are not overwritten by subsequent remote logins. See [Authorization](authorization.md) for role and policy behavior.

## Remote-user attribute synchronization

After a successful Shibboleth login and terms-of-use handling, PHAIDRA can create or update a database record for the remote user. The record can retain the supplied name, email address, affiliations, and organization units.

The private configuration option `Save remote user personal attributes` controls whether these personal attributes are written during remote login. It is enabled by default. Disabling it keeps the current remote attributes available for the login session while preserving already stored database values. This setting might be useful if saving personal data (other than username, which is saved during ToU consent already) is not desired.

## Local passwords and reset links

There is no self-registration. Administrators create local accounts and can set an initial password or send a password-reset link. A reset link can also establish the first password for an administrator-created passwordless account.

Passwords must contain at least 12 characters and at least three of these character types: lowercase letters, uppercase letters, numbers, and special characters. Password hashes, rather than passwords, are stored in MariaDB.

The public reset request accepts a username or email address, but only considers active, unexpired local accounts. Username lookup is preferred. Email-based reset is issued only when exactly one eligible local account has the supplied email address; duplicate addresses intentionally produce no reset token. The response does not reveal whether an account exists.

Reset tokens are single-use, stored as hashes, and expire after the configured lifetime (`PHAIDRA_RESET_TOKEN_TTL`, one hour by default). Reset mail uses the SMTP configuration and the configurable private email templates.

## Groups

User groups are stored in MariaDB and may contain both database and directory users. The v3.5.0 migration copies the legacy MongoDB groups into the new `groups` and `group_members` tables without deleting the original documents, so it is safe to rerun during a transition.

## Migration

Database-backed users and groups require the v3.5.0 migration:

```bash
docker exec -it phaidra-api-1 perl migrations/v3.5.0/02_add_users_groups.pl
```

The migration creates the user, affiliation, organization-unit, role, password-reset, group, and group-membership tables. It is additive and designed to be rerun safely.

## API

Administrative API endpoints are protected by the `admin_users_read` and `admin_users_write` authorization actions. The public password-reset endpoints intentionally do not require authentication. Their request and response schemas are documented in the [OpenAPI document](api.md).
