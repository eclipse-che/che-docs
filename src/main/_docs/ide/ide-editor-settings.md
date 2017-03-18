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
Editor tabs can easily get displayed in fullscreen mode by double-clicking on one of the editor's tabs. All other panes will be collapsed when you do this. To exit the fullscreen mode, double-click again on the tab.

## Fullscreen for Consoles
Console outputs and processes tabs can be displayed in fullscreen mode by double-clicking on one of the terminal's (or output's) tab to maximize it. All other panes will be collapsed when you do this. To exit the fullscreen mode, double-click again on the tab.

You can also use the quick pane option displayed in the top right corner of the pane to move to fullscreen mode.
![fullscreen-button.png]({{base}}{{site.links["fullscreen-button.png"]}})

# Preview HTML Files  
You can preview an HTML file by right-clicking it in the project explorer and selecting preview from the popup menu.

![che-previewHTML.jpg]({{base}}{{site.links["che-previewHTML.jpg"]}})

# Editor Basics

## Navigate to file

You can easily find and open a file from your workspace by going into the menu `Assistant > Navigate to File` or by using the following keyboard shortcut: `Ctrl+Alt+N`. In the `Navigate to File` wizard, enter the file's name to get a list of corresponding files found in the workspace. Open a file in the editor by selecting it or pressing `Enter` when the focus is on it.
You can use `Up`, `Down`, `Page Up`, `Page Down` on the keyboard or the mouse to scroll into the list of proposals. To close the popup press `Esc` or just click outside the wizard.

Also simple regular expression (regexp) can be used when you find a file. To replace one character you can type `?` and `*` to replace any string.

![navigate-to-file.png]({{base}}{{site.links["navigate-to-file.png"]}})

# Alternative: Use a Desktop IDE  
You can use a desktop IDE or editor with an Eclipse Che workspace by following the instructions in our [Local IDE Sync]({{base}}{{site.links["ide-sync"]}}) docs.
