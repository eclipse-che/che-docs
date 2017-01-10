---
tags: [ "eclipse" , "che" ]
title: Editor
excerpt: ""
layout: docs
permalink: /:categories/editor-settings/
---
{% include base.html %}

Che uses the [Eclipse Orion](https://orionhub.org/) editor, which provides syntax coloring, code folding, and conveniences like auto-pairing brackets.

Editor settings can be configured in the Che IDE under `Profile > Preferences > IDE > Editor`. Preferences can change key bindings, tabbing rules, language tools, whitespace and ruler preferences. All the preferences are saved per user. Note that in some cases the editor will need to be refreshed for the new settings to be applied.

You can edit your files as you would in any other editor (you can even switch to vi or emacs keybindings in `Profile > Preferences`).

![editor-prefs.png]({{base}}{{site.links["editor-prefs.png"]}})

Additionally it's possible to configure the error/warning preferences for the Java compiler at `Profile > Preferences > Java Compiler > Errors/Warnings`.

![java-compiler-prefs.png]({{base}}{{site.links["java-compiler-prefs.png"]}})

# Using Multiple Panes  

## Multi-Pane Editors
You can split the editor into multiple panes. This makes it easier to edit across different files or parts of the same file at the same time. `Split Vertical` and `Split Horizontal` can be selected through the drop down menu accessible by right clicking on a tab in the editor.

![editorpanes.gif]({{base}}{{site.links["editorpanes.gif"]}})

## Multi-Pane Consoles
You can split the consoles into multiple panes. This allows easier navigation when trying to see different console outputs at the same time. `Split Vertical` and `Split Horizontal` can be selected through the drop down menu accessible by at the top right of the console area. To put new console in a newly created pane select the open area below the tabs area.

![consolepanes.gif]({{base}}{{site.links["consolepanes.gif"]}})

# Fullscreen Mode for Panes

Editor tabs and console outputs can be displayed fullscreen.
![fullscreen.gif]({{base}}{{site.links["fullscreen.gif"]}})

## Fullscreen for Editors
Editor tabs can easily get displayed in fullscreen mode. This allows to display more content for the editor panes. You can double click on one of the editor's tab to get it maximized and displayed in fullscreen mode. It will collapse all other panes. To exit the fullscreen mode, just double click again on the editor tab.

## Fullscreen for Consoles
Console outputs and processes tabs can easily get displayed in fullscreen mode. This allows to display more content for the outputs or get a larger terminal to interact with. You can double click on one of the terminal's (or output) tab to get it maximized and displayed in fullscreen mode. It will collapse all other panes. To exit the fullscreen mode, just double click again on the terminal's (or output) tab.

You can also use the quick pane option displayed in the top right corner of the pane to get it displayed in fullscreen mode.


# Preview HTML Files  
You can preview an HTML file by right-clicking it in the project explorer and selecting preview from the popup menu.

![che-previewHTML.jpg]({{base}}{{site.links["che-previewHTML.jpg"]}})

# Alternative: Use a Desktop IDE  
You can use a desktop IDE or editor with an Eclipse Che workspace by following the instructions in our [Local IDE Sync]({{base}}{{site.links["ide-sync"]}}) docs.
