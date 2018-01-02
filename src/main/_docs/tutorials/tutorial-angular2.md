---
tags: [ "eclipse" , "che" ]
title: Angular 2
excerpt: ""
layout: tutorials
permalink: /:categories/angular2/
---
{% include base.html %}

# 1. Create Node Stack with angular/cli  

When in User Dashboard, go to **Stacks > Build Stack From Recipe** and paste the following recipe:

```text
FROM eclipse/node
RUN sudo npm install -g @angular/cli
EXPOSE 4200
LABEL che:server:4200:ref=ng-serve che:server:4200:protocol=http
```

Optional but recommended: name your new stack and give it a description, then expand the section under **Machines > DEV MACHINE**, then under
**Agents** enable language support for Typescript, JSON, and Yaml.  

# 2. Generate a project

When the workspace is up, make a new project by running these commands in the Terminal:

```
cd /projects
ng new myapp
```

You could also make a Command for this in the Command Palette.

# 3. Run App

Now, when the project is generated and all dependencies are installed, it's time to run it. Create a new command in the Command Palette, named ``Run Angular App``, with this command line:

```sh
cd ${current.project.path}
ng serve --host 0.0.0.0
```
and this preview URL:

```sh
${server.4200/tcp}
```

**Important!** Do not forget the preview URL, otherwise you will not be able to easily find the URL of your app.

Execute this command, click the preview URL link. The page should say `Welcome to app`.

# 4. Update App

In `src/app/app.component.ts` add another title by editing the existing AppComponent class:

```javascript
export class AppComponent {
  title = 'app';
  newTitle = 'indeed!';
}
```

Add the newTitle element in `src/app/app.component.html`:

```html
<h1>
  Welcome to {{ title }}, {{ newTitle }} 
</h1>
```

As soon as the server picks up changes in files, you can preview them in a running app.

