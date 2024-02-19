# Customization

There are currently 2 methods for customizing the PHAIDRA UI frontend.

## Admin settings

If you log in to PHAIDRA UI with the admin account, you can see a link to 'Admin' in the navigation. In the Admin you can set 2 things:

* choose the default template which should be used as the main submit form
* change application settings (default values are coming from phaidra-ui.js), like the repository name, the primary color, or the address of the institution

## Custom components

Components whitch are in the /components/ext directory are components which typically need to be overriden on a PHAIDRA instance (e.g. /components/ext/Header.vue). You can override these as well as other components by copying your own versions into /custom-components (e.g. /custom-components/ext/Header.vue) and rebuilding the PHAIDRA UI image.
