# Content Guidelines
## Images
Each release note gets its own folder under `imgs`. Example: `imgs/release-notes-6_0` 
When adding an image, make sure to upload it to the right folder.
Use the following syntax to refer to an image in your release note message:
`![caption]({{base}}{{site.links["filename"]}})`

## Animated GIFs
When recording an animated GIF, remember that it will be displayed on small screens. Record by zooming in your browser: usually `125%` is enough, but depending on the element you want to show, you might need to zoom in more.
For consistency: we recommand to record your animated gifs with a resolution of 800 x 600.

# Create a new release note
The release note file must be named: `release-notes-{version}.md` where `{version}` as the MAJOR_MINOR for example:`6_0`
Create a `release-notes-{version}` folder in `assets/imgs/` where contributors can work.

**Referencing the release note to the documentation:**
1- Verify the templating information in the header of the release notes (title, layout and permalink)
2- In `_data/release_notes.yml`, add the new page to the list. This is used to generate the navigation between the realease notes. Order must be lastest release note at the top.
3- In `_includes/primary-nav-items.html` make sure "Release Notes" navigation button point to the latest release note.
