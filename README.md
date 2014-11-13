Boilerplate
===========

Boilerplate code using ivanceras orm

```bash

git clone https://github.com/ivanceras/boilerplate

```


Create a database

```bash
sudo su postgres
psql

ALTER ROLE postgres with password 'p0stgr3s'

CREATE DATABASE acme WITH OWNER postgres ENCODING 'utf8';

```

Load the sample Seed Data dump located in `boilerplate/src/main/resources` to the newly created database `acme`

```bash

cd boilerplate/src/main/resources
psql -U postgres -W -h localhost -d acme -f acme_dump.sql

```

import the project as Maven project in Eclipse.

Change the configuration in `src/main/java/com/acme/AcmeConfiguration` as needed. For simplicity, we just put all the generated code in the same source folder as your other codes.


As you can see, there is an error in the some of the class files, this is because these sample classes is manipulating class files that are not yet generated in your workspace.
When I wrote those classes I have had the generated class files already.


Make sure in [`pom.xml`](https://github.com/ivanceras/boilerplate/blob/master/pom.xml), the ivanceras orm dependency is accessible, or else, you may need to checkout and build the dependencies yourself.

Run [`AcmeCodeGenerator`] (https://github.com/ivanceras/boilerplate/blob/master/src/main/java/com/acme/AcmeCodeGenerator.java)

Refresh your the project tree.

You should see that errors will be gone.

You can now start manipulating the DAO objects like the sample in [`ProductController`] (https://github.com/ivanceras/boilerplate/blob/master/src/main/java/com/acme/ProductController.java).


Enjoy playing.




