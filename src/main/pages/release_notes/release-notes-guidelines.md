## Images

Each release note gets its own folder in images directory. Example: `src/main/images/release-notes-6.0.1`
When adding an image, make sure to upload it in the right folder.
Use the following syntax to refer an image in your release notes page:

```
{% include image.html file="release-notes-${VERSION}/img.png" %}
```

## Animated GIFs

When recording an animated GIF, make sure to remember that it will be displayed on small screens. Record by zooming in your browser: usually `125%` is enough, but depending on the element you want to show, you might need to zoom in a bit more.
For consistency: we recommend to record your animated gifs with a resolution of 800*600. [Peek](https://github.com/phw/peek) is the tool we recommend to use on Linux.

## Create a New RN page

Create a new release note file in: `src/main/pages/release_notes/release-{version}.md` where `{version}` as the `MAJOR_MINOR` for example:`6_0`. If your Release Note should reference some images, see [how to publish them](#images).

## Reference Page in Navbar

1. Verify the templating information in the header of the release notes (title, layout and permalink)
2. Add a new Release Notes page to a release notes sidebar at `src/main/_data/sidebars/rn_sidebar` under `folderitems`:

```yaml
- title: 6.0.0
  url: /release-6.0.0.html
  output: web
```

3. In `src/main_data/topnav.yml` make sure "Release Notes" navigation button point to the latest release notes page - so just replace the version:

```yaml
- title: Release Notes
  url: /release-${LATEST_VERSION}.html
```
