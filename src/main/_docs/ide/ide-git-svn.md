---
tags: [ "eclipse" , "che" ]
title: Git and SVN
excerpt: ""
layout: docs
permalink: /:categories/git-svn/
---
{% include base.html %}

## Contents
- TOC
{:toc}

---



{{ site.product_formal_name }} natively supports Git and SVN, which is installed in all pre-defined stacks. Versioning functionality is available in the IDE and in the terminal. When using the Git and SVN menu, commands are injected into the workspace runtime and all output is streamed into the consoles panels. The following sections are in reference to {{site.product_mini_name}}'s IDE Git and SVN Menu.

The following sections describe how to connect and authenticate users to a remote git/svn repository. Any operations that involves authentication on the remote repository will need to be done via the IDE interface unless authentication is setup seperately for the workspace machine(terminal/commands). Authentication information setup through the following documentation are stored on {{ site.product_mini_name }} server for each user and can be used on any of the user workspaces.

# Git Using SSH Keys  
Private repositories will require a secure SSH connection and most developers who plan to push to a repo will clone it via SSH, so an SSH key pair needs to be generated. SSH keys are saved in user preferences, so you need to generate the SSH key only once and it will be used in all workspaces.

When cloning be sure to use the SSH URL like `git@<git url>:<account>/<project>.git` when importing a project from a git repository using SSH key authorization. **Note: HTTPS git URL can only be used to push changes if you enable oAuth authentication as described in [Git Using oAuth](#git-using-oauth)**.

## Generate New SSH Keys
SSH keys can be generated at `Profile > Preferences > SSH > VCS`. Use the `Generate Key` button and manually save the resulting key to your Git hosting provider account. When prompted to provide the hostname for your repo, make sure it is a bare hostname (no www or http/https) as in the example below.

![Clipboard3.jpg]({{base}}{{site.links["Clipboard3.jpg"]}})

After the key has been generated, you can view and copy it, and save to your repository hosting account.

![Clipboard4.jpg]({{base}}{{site.links["Clipboard4.jpg"]}})

## Use Existing SSH Keys
You can upload an existing public key instead of creating a new SSH key. When uploading a key add the hostname (using no www or http/https - as in the example below). Note that the `public key > view` button will not be available with this option as the public file should be generated already.

![Clipboard7.jpg]({{base}}{{site.links["Clipboard7.jpg"]}})

## Adding SSH Public Key to Repository Account
Each repository provider has their own specific way to upload SSH public keys. This is required to use features such as `push` from the Git or Subversion menu in the workspace.

## Git SSH Examples
The following example is specific to GitHub and GitLab but can be used with all git or SVN repository providers that use SSH authentication. Please refer to documentation provided by other providers for additional assistance.

### GitHub Example
To add the associated public key to a repository/account  using **github.com** click your user icon(top right) then `settings > ssh and gpg keys > new ssh key`. Give a title to your liking and paste the public key copied from Che into form.

![Clipboard5.jpg]({{base}}{{site.links["Clipboard5.jpg"]}})

![Clipboard6.jpg]({{base}}{{site.links["Clipboard6.jpg"]}})

### GitLab Example
To add the associated public key to a git repository/account  using **gitlab.com** click your user icon(top right) then `Profile Settings > SSH Keys`. Give a title to your liking and paste the public key copied from {{ site.product_mini_name }} into form.

![GitLabSSH.jpg]({{base}}{{site.links["GitLabSSH.jpg"]}})

### BitBucket Example
You can setup ssh to a dedicated BitBucket Server. Each user will still need to setup their own SSH key for authentication to the BitBucket Server which will be similar to [GitHub/GitLab SSH examples](#git-ssh-examples).

![BBS_SSH_1.jpg]({{base}}{{site.links["BBS_SSH_1.jpg"]}}){:style="width: 30%"}  

![BBS_SSH_2.jpg]({{base}}{{site.links["BBS_SSH_2.jpg"]}})

![BBS_SSH_3.jpg]({{base}}{{site.links["BBS_SSH_3.jpg"]}})

## Import Project from Repository Using SSH
Import project from the IDE `Workspace > Import Project > GIT/SUBVERSION` menu.

![Clipboard12.jpg]({{base}}{{site.links["Clipboard12.jpg"]}})

Importing a project can also be done from the dashboard menu.

![ImportProjectDashboard.jpg]({{base}}{{site.links["ImportProjectDashboard.jpg"]}})

# Git Using oAuth  

## GitHub oAuth

### Setup oAuth at GitHub
oAuth for Github allows users via the IDE git menu to import projects using SSH "git@", push to repository, and use pull request panel. To enable automatic SSH key upload to GitHub for users, register an application in your GitHub account `Setting > oAuth Applications > Developer Applications` with the callback `http://<HOST_IP>:<SERVER_PORT>/wsmaster/api/oauth/callback`:

![Clipboard8.jpg]({{base}}{{site.links["Clipboard8.jpg"]}}){:style="width: 60%"}

![Clipboard9.jpg]({{base}}{{site.links["Clipboard9.jpg"]}}){:style="width: 30%"}

### Setup environment variables.
Set the following to environment variables in the `{{ site.data.env.filename }}` file then start/restart the {{ site.product_formal_name }} server.

```YAML  
{{ site.data.env.OAUTH_GITHUB_CLIENTID }}=yourClientID
{{ site.data.env.OAUTH_GITHUB_CLIENTSECRET }}=yourClientSecret
{{ site.data.env.OAUTH_GITHUB_AUTHURI }}= https://github.com/login/oauth/authorize
{{ site.data.env.OAUTH_GITHUB_TOKENURI }}= https://github.com/login/oauth/access_token
{{ site.data.env.OAUTH_GITHUB_REDIRECTURIS }}= http://${CHE_HOST_IP}:${SERVER_PORT}/wsmaster/api/oauth/callback
```

### Using OAuth in Workspace
Once the oauth is setup, SSH keys are generated and uploaded automatically to GitHub by a user in workspace IDE `Profile > Preferences > SSH > VCS` by clicking the 'Octocat' icon.

![Clipboard.jpg]({{base}}{{site.links["Clipboard.jpg"]}}){:style="width: 60%"}

### Import Existing Project
Import project from the IDE `Workspace > Import Project > GITHUB` menu. When importing a project from GitHub using oauth key authorization you can use the https url like `https://github.com/<account>/<project>.git`.

![Clipboard13.jpg]({{base}}{{site.links["Clipboard13.jpg"]}}){:style="width: 60%"}

Importing a project can also be done from the dashboard menu.

## BitBucket Server oAuth
You can setup oAuth to a dedicated BitBucket Server to give users access to the pull request panel in their workspace. Each user will still need to setup their own SSH key for authentication to the BitBucket Server which will be similar to [GitHub/GitLab SSH examples](#git-ssh-examples).

### 1. Generate Keys
SSH to your BitBucket Server instance and generate RSA key-pairs

```shell
# generate the key pairs
$ openssl genrsa -out private.pem 1024
# copy the key and pem to a location where it can be accessed
$ openssl rsa -in private.pem -pubout > public.pub`
$ openssl pkcs8 -topk8 -inform pem -outform pem -nocrypt -in private.pem -out privatepkcs8.pem
```

### 2. Setup Codenvy in BitBucket Server
In the Bitbucket Server as an Admin:

1. Go to Administration -> Application Links
2. Enter your Codenvy URL in the 'application url' field and press the 'Create new link' button.
3. When  the 'Configure Application URL' window appears press the 'Continue' button.
4. In the ‘Link applications’ window fill in the following fields and press the 'Continue' button:
  - Application Name : Codenvy
  - Service Provider Name : Codenvy
  - Consumer key : {added by you} (Save this string, you will need it later)
  - Shared secret : {added by you}
  - Request Token URL : {your Bitbucket Server URL}/plugins/servlet/oauth/request-token
  - Access token URL : {your Bitbucket Server URL}/plugins/servlet/oauth/access-token
  - Authorize URL : {your Bitbucket Server URL}/plugins/servlet/oauth/authorize

### 3. Add Codenvy oAuth Info
In the following screen press the pencil icon to edit and select the 'Incoming Authentication' menu. Fill in the following fields in the ‘OAuth’ tab:
- Consumer Key : {the consumer key from the previous step}
- Consumer Name : Codenvy
- Public Key : {the key from public.pub file} (The key must not contain ‘-----BEGIN PUBLIC KEY-----’ and ‘-----END PUBLIC KEY-----’ rows)
- Consumer Callback : {your Codenvy URL>}/api/oauth/1.0/callback

### 4. Configure Codenvy Properties
In the `codenvy.env` file add (or change if they already exist):
- bitbucket_consumer_key : the consumer key you have entered before
- bitbucket_private_key : the key from privatepkcs8.pem file
- (The key must not contain ‘----BEGIN PRIVATE KEY-----’ and ‘-----END PRIVATE KEY-----’ rows) (The key must be specified as a single raw)
- bitbucket_endpoint : replace the default Bitbucket url by your Bitbucket Server url

### 5. Restart {{ site.product_mini_name }}
Restart your {{ site.product_mini_name }}  server to enable the integration.

## GitLab oAuth
Currently it's not possible for {{ site.product_mini_name }} to use oAuth integration with GitLab. Although GitLab supports oAuth for clone operations, pushes are not supported. You can track [this GitLab issue](https://gitlab.com/gitlab-org/gitlab-ce/issues/18106) in their issue management system.

# SVN Using Username/Password  
Import project from the IDE `Workspace > Import Project > SUBVERSION` menu. When importing a project from you can use the https url like `https://<hostname>/<repo-name>`.

![che-svn-username-password.jpg]({{base}}{{site.links["che-svn-username-password.jpg"]}}){:style="width: 60%"}

# Built-In Pull Request Panel
Within the Codenvy IDE there is a pull request panel to simplify the creation of pull requests for GitHub, BitBucket or Microsoft VSTS (with git) repositories.

# Set Git Committer Name and Email  
Committer name and email are set in `Profile > Preferences > Git > Committer`. Once set each commit will include this information.

![Clipboard2.jpg]({{base}}{{site.links["Clipboard2.jpg"]}}){:style="width: 60%"}

# Git Workspace Clients  
After importing repository, you can perform the most common Git operations using interactive menus or as terminal commands. Terminal git commands require it's own authentication setup, which means that keys generated in the IDE will work only when Git is used in the IDE menus. Git installed in a terminal is a different git system. You may generate keys in `~/.ssh` there as well.

![git-menu.png]({{base}}{{site.links["git-menu.png"]}}){:style="width: auto"}

# Git in the Project Explorer and editors  
Files in project explorer and editor tabs can be colored according to their Git Status:

![project-explorer-editor-tabs-git-colors.png]({{base}}{{site.links["project-explorer-editor-tabs-git-colors.png"]}}){:style="width: auto"}
