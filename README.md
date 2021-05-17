# Roblox-Tag-Editor
A plugin for manipulating CollectionService in Roblox Studio.

Check out the [Roblox Developer Forum post](https://devforum.roblox.com/t/tag-editor-plugin/101465) for information about what this plugin does.

## Changelog

### v3.0.0 and later

Go to the releases tab to see changelogs for version 3 and later.

https://github.com/tiffany352/Roblox-Tag-Editor/releases

### v2.1.1

- Fixed a critical error on startup due the `UI Theme` property being removed from the API.
- Switched to Plugin.Unloading API, removed that annoying "new tag editor version" print.
- Fixed the color picker being broken.

### v2.1.0

- Updated UI design. (Thanks @AmaranthineCodices!)
- Studio themes support. (@AmaranthineCodices)
- Fixed errors after reloading plugin.
- Fix delete confirmation get stuck in "Confirm" state.

### v2.0.4

- Fixed performance issue caused by tooltips.
- Fixed errors caused by updating to latest version.
- Better cleanup upon updating plugins.
- Fix bugs revealed by Studio updates.

### v2.0.3

- Tags starting with `.` no longer show up for auto-import, for ephemeral tags generated by other plugins.
- Tags starting with `.` no longer show up in world view tooltips.
- The color picker now defaults to the previous tag color.
- Fixed an error when exiting the instance view.
- Minor refactor of codebase.
- Now shows the number of instances with a tag when using the instance view.
- Fixed an error when clicking on the footer of the right click menu.
- Fixed an error in the icon picker.

### v2.0.2

- Separate search state for tag list vs icon picker.
- Show unknown tags on selected objects in tag list.
- Provide option to create tag from search term when search turns up no results.
- Show that there's no search results in tag list, this was a source of UX confusion.
- Fix error when toggling visibility on intances outside the workspace.

### v2.0.1

- Visualizing tagged attachments.
- Fix bug where objects outside the worldspace showed up in the world view.
- WorldView performance improvements.

### **v2.0.0**

- Completely rewritten plugin.
- Totally new UI design.
- Customizable icons and colors.
- Options of displaying tagged objects as a floating icon, a box, a sphere, an outline, a text label, or nothing at all.
- Button to quickly toggle visability of a tag.
- Tag list search.
- Support for PluginGui when it goes live.
- Color picker.
- Icon picker with categories and search, includes most FamFamFam Silk icons. (700+!)
- View a list of all instances with a certain tag, being able to click to select them, syncing with Studio's built in object selection.
- An option to make some tags render always on top.
- Tag groups let you group your tags together so that you can easily find them. Groups can be expanded and collapsed like sections in the Properties pane.

### v1.2
- Fixed errors when adding tags to models.
### v1.1
- Support tooltips and visually showing tagged objects in the world.
### v1.0
- Initial release.
