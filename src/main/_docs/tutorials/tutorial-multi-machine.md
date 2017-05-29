---
tags: [ "eclipse" , "che" ]
title: Multi-Machine Workspaces
excerpt: ""
layout: tutorials
permalink: /:categories/multi-machine/
---
{% include base.html %}
A multi-machine recipe allows multiple runtimes to communicate/share data. In this tutorial we will be looking at an existing Java and MySQL application called Pet Clinic. The tutorial will help show how to create a multi-machine from an existing [runtime stack]({{base}}{{site.links["devops-runtime-stacks"]}}) called "Java-MySQL", execute commands on different target runtimes, startup the Pet Clinic Tomcat server, view/interact with the Pet Clinic web page, and take a closer look at the "Java-MySQL" [runtime stack]({{base}}{{site.links["devops-runtime-stacks"]}}) /[runtime recipe]({{base}}{{site.links["devops-runtime-recipes"]}}) to get a better understanding of how multi-machine runtimes are created.

# 1. Pre-Reqs   
Use your Codenvy.io account for the following or if you are using {{ site.product_formal_name }} refer to the [getting started documentation]({{base}}{{site.links["setup-getting-started"]}}) 

# 2. Create Workspace  
Click the "Dashboard" menu item in the dashboard. Click the "New Workspace" button if there are existing workspaces or make sure "Select Source" category is set to "New from blank, template, or sample project" if one or more workspace exists.

![che-multimachine-tutorial3.jpg]({{base}}{{site.links["che-multimachine-tutorial3.jpg"]}}){:style="width: 60%"}

Select "Java-MySQL" from the list of available stacks.

![che-multimachine-tutorial1.jpg]({{base}}{{site.links["che-multimachine-tutorial1.jpg"]}}){:style="width: 60%"}

The other workspace information can remain as it is. Click the "create" button at the bottom to create the workspace.

![che-multimachine-tutorial2.jpg]({{base}}{{site.links["che-multimachine-tutorial2.jpg"]}}){:style="width: 60%"}


# 3. Using IDE  
Once the workspace is created, the IDE will be loaded in the browser.

Each runtime can be identified in the processes section of the IDE. It will list the runtimes of "dev-machine" and "db" of our multi-machine workspace. The "db" runtime for this tutorial provides the database for the Java Spring application to use.

To make sure that the database is running we will issue the "show database" command to the "db" runtime. Select the "db" runtime item from the target drop down menu. Then make sure that "show databases" is selected in the command drop down menu and hit the play button.

![che-multimachine-tutorial4.jpg]({{base}}{{site.links["che-multimachine-tutorial4.jpg"]}})

This will run the "show databases" command in the "db" runtime and display the available database at the bottom in the processes section. Note that it is not required to know the database listed for this tutorial and this step merely shows how to successfully target different runtimes.

Switch the target back to "dev-machine", select the "web-java-petclinic: build and deploy" command, and click the play button. The Pet Clinic Java code will be compiled and the tomcat server started. The tomcat server when it is ready will output `Server startup in <time> ms`. Click on the preview url link after the tomcat server is started to open the Pet Clinic web page.

![che-multimachine-tutorial6.jpg]({{base}}{{site.links["che-multimachine-tutorial6.jpg"]}})

The web page can interact in various ways with the database. Data can be added to the data by clicking the "Find owner" link, clicking the "Add owner" link, and filing in the form.

![che-multimachine-tutorial7.jpg]({{base}}{{site.links["che-multimachine-tutorial7.jpg"]}}){:style="width: 40%"}

# 4. Editing, Building and Debugging  
{{site.product_mini_name}} is a fully featured IDE that just happens to be in the browser. You can explore the [editor]({{base}}{{site.links["ide-editor-settings"]}}) which includes [intellisense]({{base}}{{site.links["ide-intellisense"]}}) for some languages and [refactoring]({{base}}{{site.links["ide-intellisense"]}}#refactoring).  It also includes [git and svn]({{base}}{{site.links["ide-git-svn"]}}) support built-in.

The example app has built in commands for [building]({{base}}{{site.links["ide-build"]}}) and [running]({{base}}{{site.links["ide-run"]}}#web-apps) the app.  You can also [debug]({{base}}{{site.links["ide-debug"]}}) right inside Che.

# 5. About Docker and Compose  
Read this section to understand more about the multi-machine "Java-MySQL" [runtime stack]({{base}}{{site.links["devops-runtime-stacks"]}}) used and its [runtime recipe]({{base}}{{site.links["devops-runtime-recipes"]}}). The "Java-MySQL" stack configuration is located in the "stacks" section in the dashboard. This stack can be found easier by typing "java" in the filter form.

![che-multimachine-tutorial8.jpg]({{base}}{{site.links["che-multimachine-tutorial8.jpg"]}})

Click on the "Java-MySQL" menu item which will bring up the stack's configuration page. There is various useful configuration information provided on this page as well as the [Runtime Stacks]({{base}}{{site.links["devops-runtime-stacks"]}}) and [Runtime Recipes]({{base}}{{site.links["devops-runtime-recipes"]}}) documentation pages. For this tutorial, we will be focusing on the recipe configuration and dockerfile provided in the "Java-MySQL" stack.

The recipe uses docker compose syntax. Due to the limitation of the JSON syntax the compose recipe is written as a single line with `\n` indicating carriage return. The following is the recipe in expanded form to make reading easier.

```yaml    
services:
 db:
  image: mysql
  environment:
   MYSQL_ROOT_PASSWORD: password
   MYSQL_DATABASE: petclinic
   MYSQL_USER: petclinic
   MYSQL_PASSWORD: password
  mem_limit: 1073741824
 dev-machine:
  image: eclipse/ubuntu_jdk8
  mem_limit: 2147483648
  depends_on:
    - db
```

Examining the code above you will see our two runtime machines "db" and "dev-machine". Every workspace requires a [machine]({{base}}{{site.links["devops-runtime-machines"]}}) named "dev-machine".

In the recipe the `depends_on` parameter of the "dev-machine" allows it to connect to the "db" machine MySQL process' port 3306. The "dev-machine" configures its MySQL client connection in the projects source code at `src/main/resources/spring/data-access.properties`. The url is defined by `jdbc.url=jdbc:mysql://db:3306/petclinic` which uses the database machine's name "db" and the MySQL server default port 3306.

Port 3306 is exposed in the "db" machines Dockerfile during build but is not required for "dev-machine" to connect to it. Exposing port 3306 is done to provide access to database that is external to "db" machine network via a random ephemeral port assigned by docker. The "dev-machine" by setting `depends_on: - db` creates a private network that allows it use of "db" machine's name as hostname and port 3306 without having to determine the ephemeral port docker assigned.

Exposing port 3306 is done to provide an option for an external administrator to log into the "db" machine MySQL server through a MySQL client on the ephemeral port assigned. The workspace runtime configuration interface provides the external ephemeral ports assigned by docker for all machines' exposed ports. Image below indicates only external ephemeral port 32778 assigned to "db" machine's exposed port 3306.

![che-mysql-tutorial1.jpg]({{base}}{{site.links["che-mysql-tutorial1.jpg"]}})

The "db" machine contains a MySQL database created by MySQL's official Docker image "mysql". Within MySQL runtime information for the "db" machine there are four environment variables set that are used by [MySQL docker image's entrypoint script](https://github.com/docker-library/mysql/blob/master/5.7/docker-entrypoint.sh) that sets the database name and authentication information. 

![che-multimachine-tutorial9.jpg]({{base}}{{site.links["che-multimachine-tutorial9.jpg"]}}){:style="width: 80%"}
