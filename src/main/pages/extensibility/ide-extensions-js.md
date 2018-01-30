---
title: "IDE Extensions: JavaScript"
keywords: framework, extensions, javascript, typescript, client side
tags: [extensions, assembly, dev-docs]
sidebar: user_sidebar
permalink: ide-extensions-js.html
folder: extensibility
---

{% include links.html %}

## Quick-Start

Before we focus on the mechanism of extending Eclipse Che IDE with JS plugins, let's run a sample JS plugin in Che. Since this is an experimental API and a new extension mechanism in general, there's a dedicated Docker image with binaries [built from a branch](https://github.com/eclipse/che/tree/runJsPlugin). There are multiple ways to try this branch.

**On Docker:**

* build it yourself: `mvn clean install` in Che repository root and then:

`docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v /path/to/che/repo/root:/repo -v /local/data/path:/data eclipse/che:nightly -e "CHE_PREDEFINED_STACKS_RELOAD__ON__START=true" start --skip:scripts` OR

* pull a ready to use image (recommended!):

`docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v /local/data/path:/data -e "CHE_PREDEFINED_STACKS_RELOAD__ON__START=true" -e "IMAGE_CHE=eivantsov/che:js" eclipse/che:nightly start`

`CHE_PREDEFINED_STACKS_RELOAD__ON__START=false` is required only if you use an existing local data directory for Che, otherwise, if it's a new dir, drop the env.

**On MiniShift:**

Create a new Che server deployment:

```bash
export CHE_IMAGE_REPO=eivantsov/che
export CHE_IMAGE_TAG="js"
export CHE_PREDEFINED_STACKS_RELOAD__ON__START=true
git clonre https://github.com/eclipse/che # (or wget/curl the script below)
cd dockerfiles/init/modules/openshift/files/scripts/
./deploy_che.sh
```
When on MiniShift, it is recommended to execute the following commands before you proceed to make sure you get an updated stack image:

```
minishift ssh
docker pull eclipse/che-dev:nightly
```
Deployment to OCP may require additional envs. See: [Deploy to OpenShift](openshift.html#openshift-container-platform)

**Create a Workspace**

Search for a `Che` stack, choose JS Plugin Tools stack and `che-ide-ts-extension` as a sample project. Create and start a workspace.

{% include image.html file="devel/js_ws.png" %}

**Commands**

When in a running, workspace, you may want to expand a plugin in the project tree, navigate through files, try TypeScript Language Server capabilities like autocompletion.

Let's install dependencies for a sample plugin by executing **installDeps** command:  

{% include image.html file="devel/js_ws_commands.png" %}

This command downloads Che API dependencies runs `npm link` - at this moment Che JS API package isn't published as a global npm module. We plan publishing it soon, and it will be listed in plugin's `package.json` as a dependency, so `npm install` will download it to `node_modules`.

Once dependencies are installed, let's build and install a plugin with **installPlugin** command. This command does the following things:

* `npm install` - get dependencies as node_modules
* `npm link eclipse-che` - grab eclipse-che module fetched in a previous command
* `npm run bundle` - building the plugin using webpack into `dist/bundle.js`. This script is then referenced in package.json that Che rest service gets when the IDE is initialized
* `rm -rf $CHE_JS_PLUGIN_DIR/redhat.che-js-plugin-3.0.0 && mkdir -p $CHE_JS_PLUGIN_DIR/redhat.che-js-plugin-3.0.0` - make sure a plugin directory is empty before copying the plugin. Che REST service will look for all directories in `CHE_JS_PLUGIN_DIR` (which is `/home/user/che/js-plugins` in our case) that have certain naming pattern - `publisher.plugin-version`  
* `cp -R ${current.project.path}/* $CHE_JS_PLUGIN_DIR/redhat.che-js-plugin-3.0.0` - copy plugin to a directory from where Che IDE will pick it up. As of now, this directory is sort of a local plugin registry. This is temporary until a proper registry and plugin delivery mechanism is implemented.

You will also see a preview URL, which is basically your workspace URL with `?pluginServer=${server.wsagent/http}` query parameter that signals the IDE to look for plugins in `$CHE_JS_PLUGIN_DIR` when initializing.

Click this preview URL, go to **Help** menu:

{% include image.html file="devel/js_plugin.png" %}

You will see new actions that will show and hide a new part (with a clock).

{% include image.html file="devel/js_plugin_clock.png" %}

Get back to your workspace, open `package.json`, look for menu items like `Show Part` or `JS Group` in actions list. Change the titles, execute **installPlugin** command, return to plugin preview tab and refresh it - you should see your changes there.

Now that you have deployed your first JS plugin in Che, let's look at how things work.

## How It Works

Below is a high level overview of plugin delivery and loading. JavaScript plugin development flow **does not imply replacing GWT extensions**. The monolithic GWT script compiled from GWT code is still loaded into IDE.html. However, the client exposes [JavaScript extension points](https://github.com/eclipse/che/tree/che6-js-plugin/ide/che-core-ide-js-api/src/main/java/org/eclipse/che/ide/js/api) that a JavaScript plugin can make use of (you will see interfaces annotated with `@JsType`), and a plugin loading mechanism (you may want to take a look at [PluginManager](https://github.com/eclipse/che/blob/che6-js-plugin/ide/che-core-ide-js-api/src/main/java/org/eclipse/che/ide/js/plugin/PluginManager.java). Server side is represented by a REST service that looks for plugins in a particular location and returns a list with contents of `package.json` files.

{% include image.html file="devel/js_flow.png" url="images/devel/js_flow.png" caption="Click to view a larger image" %}


When IDE activates a plugin it calls activate function and passes the object which contains all IDE API. Argument that passed to activate function is:

```js
 declare interface PluginContext {
    getApi(): CheApi;
    addDisposable(d: Disposible): void
}
```

## package.json

Each plugin has `package.json` with a set of mandatory and optional properties:

| Property          | Type   | Description                                                                              | Mandatory |
| ------------------| ------ | -----------------------------------------------------------------------------------------| ---------
|**name**               | string | name of the plugin, only lowercase and dash                                              | yes
|**version**            | string | version of the plugin                                                                    | yes
|**publisher**          | string | unique identificator of the person or organization whom publish plugin.                  | yes
|**engines**            | object | which has one property - `che` and value is minimal compatible version of the Che.       | yes
|**main**               | string | path to the main js file which IDE will load.                                            | yes
|**loader**             | string | possible values is “AMD” or “GWT” (reserved for future)                                  | yes
|**description**        | string | short description, may be used for plugin store                                          | no
|**displayName**        | string | name, may be used for plugin store                                                       | no
|**keywords**           | array  | contains keywords, may be useful for search in plugin store                              | no
|**pluginDependencies** | array  | contains plugin ids. Plugin ID format is `{publisher}.{name}`                            | no
|**contributes**        | object | contains plugin contributes description.                                                 | no

Sample plugin [package.json](https://github.com/evidolob/che-js-plugin/blob/master/package.json)

## Contributes Object

This declarative part of `package.json` contains actions, groups and themes.

**images** - array of image objects that contains image description object.

Image object contains mandatory **id** property which is a unique string identifier and one of two options: `url` - the image URL string or “html” - the image html template, may be used for instance for FontAwesome icons.

```js
"images": [
     {
       "id": "cjp.image1",
       "url": "https://png.icons8.com/download-from-cloud/ios7/32"
     },
     {
       "id": "cjp.image2",
       "html": "<i class=\"fa fa-bath\" aria-hidden=\"true\"></i>"
     }
   ]
```

**actions** - array of action description objects that can be of two types: **action** or **group**.

Action object is object that describe some action. Action object contains:

* **id** - mandatory,  unique string identifier, with action will be registred in ActionManager
* **text** - mandatory, string that represents action text (for example in main menu)
* **description** - optional, string that shows in action tooltip
* **icon** - optional, string image id, Image element will be taken from ImageRegistry using id.
* **addToGroup** - array of  AddToGroup objects, specifies that the action should be added to an existing group. Action may be added to several groups. Object structure is:
* **groupId** - mandatory, action group id to which the action is added.
* **anchor** - mandatory, specify the position in the group. Can have values: “first”, “last”, “before” or “after”.
* **relativeTo** - mandatory if anchor set to:”before” or “after”, specifies the action before or after action is inserted.
* **keybinding** - object that describe keyboard shortcut for this action. Object contains fields : “win”, “linux”, “mac” which describes shortcut for all main OS. // TODO specify the keybinding format

```js
{
       "action": {
         "id": "cjp.test.action",
         "text": "Hello JS API",
         "description": "First Action From JS Plugin",
         "icon": "cjp.image1",
         "addToGroup": [
           {
             "groupId": "helpGroup",
             "relativeTo": "someAction",
             "anchor": "before"
           }
         ],
         "keybinding": {
           "win": "",
           "linux": "",
           "mac": ""
         }
       }
     }
```

Group object describes an action group. All actions, groups and separators described in this object are automatically included in the group. Group object has:

* **id** - mandatory,  unique string identifier with which group will be registered in `ActionManager`
* **text** - optional, string that represents group text (if group used as sub menu)
* **description** - optional, string that shows group tooltip
* **icon** - optional, string image id, image element will be taken from `ImageRegistry` by its id
* **popup** - optional, boolean specifies how group presented in menu. If ‘true’, actions in it placed as sub-menu. If ‘false’, actions in it displayed as a section of the same menu delimited by separators
* **addToGroup** - array of  `AddToGroup` objects, see Action description
* **actions** - array, contains group, action, reference or delimiter :
* **action** - see Action description
* **group** - see Group description
* **reference** - object, allows to add an existing action to the group. Has one mandatory property “ref” which contains action id to add.
* **separator** - string constant, defines a separator between actions.

```js
{
       "group": {
         "id": "cjp.test.group",
         "text": "JS Group",
         "description": "JS Test Group",
         "icon": "cjp.image2",
         "popup": true,
         "addToGroup": {
           "groupId": "helpGroup",
           "relativeTo": "someAction",
           "anchor": "last"
         },
         "actions": [
           {
             "action": {
               "id": "cjp.action.in.group",
               "text": "Action in Group",
               "description": "Action defined in group",
               "icon": "cjp.imageFactory"
             }
           },
           "separator",
           {
             "group": {
               "id": "cjp.group.in.group"
             }
           },
           {
             "reference": "cjp.test.action"
           }
         ]
       }
     }
```

**themes**  - array of object that describe theme, object contains 3 mandatory properties:

* **id** - string, the theme id
* **description** - string,  the theme description, used in theme selection dialog
* **path** - string, the path to the theme json file that contains all theme properties

```js
"themes":[
     {
       "id": "js.theme",
       "description": "Theme Form JS Plugin",
       "path": "theme/theme.json"
     }
   ]
```

Example of `theme.json` can be found [here](https://github.com/evidolob/che-js-plugin/blob/master/theme/theme.json)

## JS API/Helper File

Before plugin is packaged as a final script with webpack, Che API dependency needs to be installed first (**installDeps** command in the [quick-start](#quick-start)). You can take a look at [index.d.ts](https://github.com/eclipse/che/blob/che6-js-plugin/che-types/index.d.ts) which is well documented and is being updated and maintained. You will find all extension points that the IDE offers and an easy way to implement interfaces.

## addDisposable

 Used to store any plugin relative disposable object. When plugin is deactivated IDE will call dispose method for all added Disposable objects.

## imageRegistry

Holds and manages all IDE icon resources, each resource mapped to their id. There are 3 ways to provide an image: URL, HTML, image element factory.

TypeScript Declaration:

```js
declare interface ImageRegistry {
   /**
    * Register image url.
    *
    * @param id the image id
    * @param url the image url
    */
   registerUrl(id: string, url: string): Disposable;
   /**
    * Register image html. For example html may be some FontAwesome icon
    *
    * @param id the image id
    * @param html the image html
    */
   registerHtml(id: string, html: string): Disposable;
   /**
    * Register image factory. For example : factory may provided by GWT plugin which use ClientBundle for images or plugin may construct image element manually.
    *
    * @param id the image id
    * @param factory the image factory
    */
   registerFactory(id: string, factory: ImageFactory): Disposible;
   /**
    * Returns new image element each time
    *
    * @param id the image id
    * @return the image element or null if no image provided
    */
   getImage(id: string): Element;
}
/**
* Factory to create some image Element, for example it's may be from GWT Image/SVG resource.
* Should return new element each time called.
*/
declare interface ImageFactory {
   (): Element;
}
```

## actionManager

A manager for actions which is used to register action handlers.

TypeScript Declaration:

```js
interface ActionManager {
  /**
   * Register action handlers.
   * @param actionId the action id
   * @param updateAction the update handler This method can be called frequently,          for instance, if an action is added to a toolbar, it will be updated twice a second.     This means that this method is supposed to work really fast, no real work should be done at this phase.
      * @param performAction the perform handler
      */
   registerAction(actionId: string, updateAction: UpdateAction, performAction:()=>void): Disposible;
}
interface UpdateAction {
   /**
    * Updates the state of the action.
    * This method can be called frequently, for
    * instance, if an action is added to a toolbar, it will be updated twice a second. This means
    * that this method is supposed to work really fast, no real work should be done at this phase.
    *
    * @param actionData the action state data
    */
   (d: ActionData): void;
}
interface ActionData {
   getText(): string;
   setText(text: string): void;
   getDescription(): string;
   setDescription(description: string): void;
   getImageElement(): Element;
   setImagetElement(imageElement: Element): void;
   isVisible(): boolean;
   setVisible(visible: boolean): void;
   isEnabled(): boolean;
   setEnabled(enabled: boolean): void;
   setEnabledAndVisible(enabled: boolean): void;
}
```

## partManager

Handles IDE Perspective, allows to open/close/switch Parts, manages opened Parts. Parts represent the content of the Che workbench, i.e. views and editors within the IDE. Che already provides various parts such as the project explorer, the output console, the build result view, file outline and the code editor. In this part of the tutorial, we describe how to implement a custom view and embed it into the Che IDE.

```js
declare interface PartManager {
   /**
  * Sets passed part as active. Sets focus to part and open it.
  *
  * @param part part which will be active
  */
   activatePart(part: Part): void;
   /**
    * Check is given part is active
    *
    * @return true if part is active
    */
   isActivePart(part: Part): boolean;
   /**
    * Opens given Part
    *
    * @param part
    * @param type
    */
   openPart(part: Part, type: che.ide.parts.PartStackType): void;
   /**
    * Hides given Part
    *
    * @param part
    */
   hidePart(part: Part): void;
   /**
    * Remove given Part
    *
    * @param part
    */
   removePart(part: Part): void;
}
declare interface Part {
   /** @return Title of the Part */
   getTitle(): String;
   /**
    * Returns count of unread notifications. Is used to display a badge on part button.
    *
    * @return count of unread notifications
    */
   getUnreadNotificationsCount(): number;
   /**
    * Returns the title tool tip text of this part. An empty string result indicates no tool tip. If
    * this value changes the part must fire a property listener event with <code>PROP_TITLE</code>.
    *
    * <p>The tool tip text is used to populate the title bar of this part's visual container.
    *
    * @return the part title tool tip (not <code>null</code>)
    */
   getTitleToolTip(): String;
   /**
    * Return size of part. If current part is vertical panel then size is height. If current part is
    * horizontal panel then size is width.
    *
    * @return size of part
    */
   getSize(): number;
   /**
    * This method is called when Part is opened. Note: this method is NOT called when part gets
    * focused. It is called when new tab in PartStack created.
    */
   onOpen(): void;
   /** @return */
   getView(): Element;
   getImageId(): String;
}
 enum PartStackType {
               /**
            * Contains navigation parts. Designed to navigate by project,          types, classes and any other
            * entities. Usually placed on the LEFT side of the IDE.
            */
               NAVIGATION,
               /**
                * Contains informative parts. Designed to display the state of the application, project or
                * processes. Usually placed on the BOTTOM side of the IDE.
                */
               INFORMATION,
               /**
                * Contains editing parts. Designed to provide an ability to edit any resources or settings.
                * Usually placed in the CENTRAL part of the IDE.
                */
               EDITING,
               /**
                * Contains tooling parts. Designed to provide handy features and utilities, access to other
                * services or any other features that are out of other PartType scopes. Usually placed on the
                * RIGHT side of the IDE.
                */
               TOOLING
           }
```

## editorManager

Manages Editors, it allows to open a new editor with given file, retrieve current active editor and find all the opened editors.

For now editor manager has two methods for editor and file related events:

`addFileOperationListener(listener: { (event: FileOperationEvent): void }):Disposable;`

and

```js
addEditorOpenedListener(listener: { (event: EditorOpenedEvent): void }):Disposable;
declare interface EditorOpenedEvent {
   getFile(): VirtualFile;
   getEditor(): EditorPartPresenter;
}
declare interface EditorPartPresenter {
 //TODO
}
declare interface FileOperationEvent {
   getFile(): VirtualFile;
   getOperationType(): che.ide.editor.FileOperation
}
declare interface VirtualFile {
   getLocation(): String;
   getName(): String;
   getDisplayName(): String;
   isReadOnly(): boolean;
   getContentUrl(): String;
}
```


## eventBus

The class `com.google.web.bindery.event.shared.EventBus` which used in IDE to fire and listen events, but it’s a GWT class and it’s not possible to expose it to JS. Also all events that  `EventBus` can handle should extend `com.google.web.bindery.event.shared.Event` class which is not possible in JS code. So, a new `EventBus` and event system is provided. For now, only a few events will be transmitted to a new `EventBus`.

```js
eventBus - EventBus object:
declare interface EventBus {
   fire<E>(type: EventType<E>, event: E): EventBus;
   addHandler<E>(type: EventType<E>, handler: { (event: E): void });
}
declare interface EventType<E> {
   type(): string;
}
```

Sample code:

```js
ctx.getApi().eventBus.addHandler(che.ide.editor.FileOperationEvent.TYPE, e => {
       console.log(e.getFile().getLocation() + "@" + e.getOperationType());
 });
```

Editor related events:

```js
enum FileOperation {
               OPEN,
               SAVE,
               CLOSE
           }
  class FileOperationEvent {
               static TYPE: EventType<FileOperationEvent>;
               getFile(): VirtualFile;
               getOperationType(): che.ide.editor.FileOperation
   }
   class EditorOpenedEvent {
               static TYPE: EventType<EditorOpenedEvent>;
               getFile(): VirtualFile;
               getEditor(): EditorPartPresenter;
  }
```
Workspace server events:

```js
class ServerRunningEvent {
                   static TYPE : EventType<ServerRunningEvent>;
                   getServerName(): string;
                   getMachineName(): string;
               }
               class WsAgentServerRunningEvent {
                   static TYPE : EventType<WsAgentServerRunningEvent>;
                   getMachineName(): string;
               }
               class TerminalAgentServerRunningEvent {
                   static TYPE : EventType<TerminalAgentServerRunningEvent>;
                   getMachineName(): string;
               }
               class ExecAgentServerRunningEvent {
                   static TYPE : EventType<ExecAgentServerRunningEvent>;
                   getMachineName(): string;
               }
               class ServerStoppedEvent {
                   static TYPE : EventType<ServerStoppedEvent>;
                   getServerName(): string;
                   getMachineName(): string;
               }
               class WsAgentServerStoppedEvent {
                   static TYPE : EventType<WsAgentServerStoppedEvent>;
                   getMachineName(): string;
               }
               class TerminalAgentServerStoppedEvent {
                   static TYPE : EventType<TerminalAgentServerStoppedEvent>;
                   getMachineName(): string;
               }
               class ExecAgentServerStoppedEvent {
                   static TYPE : EventType<ExecAgentServerStoppedEvent>;
                   getMachineName(): string;
               }
```

## dialogManager

Dialog Manager allows displaying Message, Confirm, Input and Choice dialogues. A message dialogue consists of a title, body/content and confirmation button. Confirmation button text is 'OK' by default, but it can be overridden.

Arguments passed to display the dialog:

* `dialogData: MessageDialogData` - the information necessary to create a Message dialog window
* `confirmButtonClickedHandler: ClickButtonHandler` - the handler is used when user click on confirmation button

**DialogData** contains fields:

* `title: string` - title of dialog
* `content: string` - content for displaying

`MessageDialogData` extends `DialogData` and allows to override Confirmation button text:

`confirmButtonText: string` - confirmation button named 'OK' by default

Confirmation dialog consists of a title, main part with text as content, confirmation and cancel buttons. Text for confirmation and cancel buttons can be overridden.

Arguments that passed to display the dialog are:

* `dialogData: ConfirmDialogData` - information necessary to create a Confirmation dialog window
* `confirmButtonClickedHandler: ClickButtonHandler` - the handler is used when confirmation button is clicked
* `cancelButtonClickedHandler: ClickButtonHandler` - the handler is used when cancel button is clicked
* `ConfirmDialogData` extends `MessageDialogData` and allows to override Cancel button text:
* `cancelButtonText: string` - cancel button named 'Cancel' by default

Input dialog consists of a title, main part with input field and label for it, confirmation and cancel buttons. Text for confirmation and cancel buttons can be overridden. It’s possible to initialize Input field by initial text. The initial text may be pre-selected.

Arguments that passed to display the dialog are:

* `dialogData: InputDialogData` - the information necessary to create an Input dialog window
* `inputAcceptedHandler: InputAcceptedHandler` - the handler is used when user click on confirmation button
* `cancelButtonClickedHandler: ClickButtonHandler` - the handler is used when user click on cancel button
* `InputDialogData` extends `ConfirmDialogData` and contains fields:
* `initialText: string` - text used to initialize the input, may be pre-selected. Selection begins at the specified `{@code selectionStartIndex}`` and extends to the character at index ``{@code selectionLength}`.
* `selectionStartIndex: number` - beginning index of the initial text to select, inclusive.
* `selectionLength: number` - number of characters to be selected in the input.

Choice dialog consists of a title, main part with text as content and three buttons to confirm some choice.

Arguments that passed to display the dialog are:

* `dialogData: ChoiceDialogData` - the information necessary to create a Choice dialog window
* `firstButtonClickedHandler: ClickButtonHandler` - handler is used when the first button on the right is clicked
* `secondButtonClickedHandler: ClickButtonHandler` - handler is used when the second button on the right is clicked
* `thirdButtonClickedHandler: ClickButtonHandler` - handler is used when the third button on the right is clicked
* `ChoiceDialogData` extends `DialogData` and contains fields:
* `firstChoiceButtonText: string` - text to display in first choice button.
* `secondChoiceButtonText: string` - text to display in second choice button
* `thirdChoiceButtonText: string` - text to display in third choice button
