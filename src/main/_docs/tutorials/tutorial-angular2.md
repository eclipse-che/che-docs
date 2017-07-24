---
tags: [ "eclipse" , "che" ]
title: Angular 2
excerpt: ""
layout: tutorials
permalink: /:categories/angular2/
---
{% include base.html %}

# 1. Create Node Stack with angular/cli  

When in User Dashboard, go to **Workspaces > Add Workspace > Runtime > Stack Authoring** and paste the following recipe:

```text
FROM codenvy/node
RUN sudo npm install -g angular-cli
EXPOSE 4200
LABEL che:server:4200:ref=ng-serve che:server:4200:protocol=http
```

# 2. Generate a project

When the workspace is up, create the following command:

```
cd /projects
ng new myapp
```

You can perform the above commands in the Terminal too.

# 3. Run App

Now, when the project is generated and all dependencies are installed, it's time to run it. Create yet another command:

```text
cd ${current.project.path}
ng serve --host 0.0.0.0
```
Important! Make sure this command has preview URL as follows:

``${server.4200/tcp}``

Execute this command, click the preview URL link. The page should say `app works`

# 4. Update App

In `src/app/app.component.ts` add another title by editing the existing AppComponent class:

```javascript
export class AppComponent {
  title = 'app works!';
  newTitle = 'Indeed!';
}
```

Add the newTitle element in `src/app/app.component.html`:

```
<h1>
  {{bracesLeft}}title{{bracesRight}}
  <br>
  {{bracesLeft}}newTitle{{bracesRight}}
</h1>
```

As soon as the server picks up changes in files, you can preview them in a running app
