---
tags: [ "eclipse" , "che" ]
title: PHP in Che
excerpt: ""
layout: tutorials
permalink: /:categories/php/
---
{% include base.html %}
# 1. Create a PHP Project  
Start Che, create a PHP project using a sample app:

![php.png]({{base}}{{site.links["php.png"]}})

# 2. Explore and Modify the Project Code

The sample project contains just a simple "Hello World!" script written in PHP. 

Expand the project's source tree in the Project Explorer panel on the left side of the screen. Double-click on the `index.php` file to open it in the PHP editor.

The `index.php` file contains a single instruction that will print "Hello World!" to the standard output.

```php
<?php

echo "Hello World!";
```

You can use the editor to edit the script. The PHP editor provides rich [IntelliSense]({{base}}{{site.links["ide-intellisense"]}}) features like syntax hightlighting, code completion, code validation, code navigation, etc.

# 3. Execute as a Script

The PHP stack has the `run php script` command that allows you to run the currently opened PHP file as a CLI script, i.e. the output of the PHP script will be printed in the Terminal panel.

While you have the `index.php` file on focus in the PHP editor, run the `run php script` command in the CMD command widget. "Hello World!" will be printed in the Terminal panel.

# 4. Run as a Web App

The PHP stack includes the Apache Web Server and has commands for starting, stopping and restarting it.

`start apache` will start the server and tail apache error and access logs. It will also produce a preview URL that will point to your current project directory that Apache is already listening (Document root is changed to `projects`).

You should see a Hello World page. Open `index.php`, edit it, refresh the preview page in your browser to see live changes.

# 5. Debug

The PHP stack includes the Zend Debugger module, which allows debugging PHP both as CLI script and Web app. See the [Debug - PHP]({{base}}{{site.links["ide-debug"]}}#php) page for details.

# 6. Composer and Unit Tests  
A PHP stack has [Composer](https://getcomposer.org/) already installed and configured. Composer is used to manage project dependencies, i.e. makes it easy to use 3rd party libs and frameworks.

Let's add the [PHPUnit](https://phpunit.de/) testing framework and write a simple Unit test.

In project root, create `composer.json` file with the following contents:

```json
{
    "require": {
        "phpunit/phpunit": "5.7.*"
    }
}
```

The JSON editor provides IntelliSense too. It provides code completion and validation according to the composer.json schema.

In the `Processes` panel, click New Terminal (+) button. This will open up a bash terminal:

```sh
$ cd /projects/web-php-simple
$ composer update --no-dev
```

This will install the `phpunit` framework into `vendor` directory in the project.

Now, let's write a simple test. Create a `test.php` file:

```php
<?php

require_once 'vendor/autoload.php';

class SimpleTest extends PHPUnit_Framework_TestCase {

    public function testTrueIsTrue() {
        $foo = true;
        $this->assertTrue($foo);
    }
}
```

This test basically checks nothing but demonstrates use of composer-provided frameworks. Having required `vendor/autoload.php` it is possible to use any functions of `phpunit`.

Run the test:

```sh
$ vendor/bin/phpunit test.php
PHPUnit 5.7.9 by Sebastian Bergmann and contributors.

.                                                                   1 / 1 (100%)

Time: 27 ms, Memory: 2.75MB

OK (1 test, 1 assertion)
```

# 7. Create a REST Service With Slim  
Slim makes it possible to create REST services. Let's add this framework to `composer.json`:

```json
{
    "require": {
        "phpunit/phpunit": "5.7.*",
        "slim/slim": "2.*"
    }
}
```
Run `composer update --no-dev` to download all `slim` dependencies. The framework is ready to be used now. Let's modify `index.php` so that it looks like this:

```php
<?php

require 'vendor/autoload.php';

$app = new \Slim\Slim();

$app->get('/:name', function ($name) {
   echo "Hello $name";
});

$app->run();
```

This script creates a REST service that takes a path parameter and returns it as `Hello $pathParam`. So, `http://<your-che-host>:$port/$appName/Che` should return `Hello Che`.

This app will need mod_rewrite enabled to avoid using an ugly URL with `index.php` in the path. In the project root, create a `.htaccess` file:

```text
RewriteEngine on
RewriteRule ^ index.php [QSA,L]
```
Apache needs to be restarted. Run `restart apache` command in the CMD command widget.

Now, navigate to `http://<your-che-host>:$port/$project/Che` to find `Hello Che` in a response:

![slim.png]({{base}}{{site.links["slim.png"]}})
