# Authorization

Following rules apply when authorizing an operation on a digital object:

* Any authenticated user can upload objects.

* The account which uploaded the object is declared as the **owner** of the object. What this means in the legal sense is typically explained in terms of use which vary from institution to institution, here we will only consider what it means in terms of repository authorisation mechanisms.

* Part of the authentication process is usually fetching various attributes of the users. What attributes are fetched depends on the authentication mechanism which was integrated, but typically, these attributes are relevant for authorization: 
    * username
    * admin role
    * superuser role
    * groups
    * affiliations

* Only **admin**, **superuser** or the **owner** of the object can edit objects metadata and access restrictions, change it's relationships, or delete the object.

* All **active** objects are visible to everybody. If access restrictions are defined, datastreams like OCTETS, FULLTEXT and WEBVERSION or any custom datastreams are only accessible for users defined in the restrictions (using usernames, groups or affiliations). However, basic object properties, relationships and metadata datastreams (JSON-LD, UWMETADATA, MODS, ANNOTATIONS, etc) are still visible for everyone.

* **Inactive** objects are only accessible/visible for **admin**, **superuser** or for the **owner**.

* Only **admin** and accounts defined in configuration are allowed to change the ownership of an object.

## Future work

It is planned to develop the possibility to restrict upload only to users with specific attributes.