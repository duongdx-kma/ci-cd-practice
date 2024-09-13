## I. Maven Default Lifecycle

| **Phase**               | **Description**                                                                 |
|-------------------------|---------------------------------------------------------------------------------|
| **validate**            | Validate the project is correct and all necessary information is available.     |
| **initialize**          | Initialize build state, e.g. set properties or create directories.              |
| **generate-sources**    | Generate any source code for inclusion in compilation.                          |
| **process-sources**     | Process the source code, for example to filter any values.                      |
| **generate-resources**  | Generate resources for inclusion in the package.                                |
| **process-resources**   | Copy and process the resources into the destination directory, ready for packaging. |
| **compile**             | Compile the source code of the project.                                          |
| **process-classes**     | Post-process the generated files from compilation, for example to do bytecode enhancement on Java classes. |
| **generate-test-sources** | Generate any test source code for inclusion in compilation.                    |
| **process-test-sources** | Process the test source code, for example to filter any values.                 |
| **generate-test-resources** | Create resources for testing.                                                |
| **process-test-resources** | Copy and process the resources into the test destination directory.           |
| **test-compile**        | Compile the test source code into the test destination directory.                |
| **process-test-classes** | Post-process the generated files from test compilation, for example to do bytecode enhancement on Java classes. |
| **test**                | Run tests using a suitable unit testing framework. These tests should not require the code be packaged or deployed. |
| **prepare-package**     | Perform any operations necessary to prepare a package before the actual packaging. This often results in an unpacked, processed version of the package. |
| **package**             | Take the compiled code and package it in its distributable format, such as a JAR. |
| **pre-integration-test** | Perform actions required before integration tests are executed. This may involve things such as setting up the required environment. |
| **integration-test**    | Process and deploy the package if necessary into an environment where integration tests can be run. |
| **post-integration-test** | Perform actions required after integration tests have been executed. This may include cleaning up the environment. |
| **verify**              | Run any checks to verify the package is valid and meets quality criteria.        |
| **install**             | Install the package into the local repository, for use as a dependency in other projects locally. |
| **deploy**              | Done in an integration or release environment, copies the final package to the remote repository for sharing with other developers and projects. |


## II. Maven install
### 1. install maven
```powershell
yum update -y

# Install Amazon Corretto 17 (OpenJDK 17)
rpm --import https://yum.corretto.aws/corretto.key
curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
yum install -y java-17-amazon-corretto-devel

# Install Maven
MAVEN_VERSION=3.9.5
MAVEN_DIR=/opt/maven

wget https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
mkdir -p $MAVEN_DIR
tar -xvzf apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_DIR
ln -s $MAVEN_DIR/apache-maven-$MAVEN_VERSION /opt/maven/latest
ln -s /opt/maven/latest/bin/mvn /usr/bin/mvn

# Verify Maven installation
mvn -version
```

### 2. install maven other maven version
```powershell
#!/usr/bin/env bash

MAVEN_VERSION=3.9.9
MAVEN_DIR=/opt/maven

wget https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O ~/apache-maven-$MAVEN_VERSION-bin.tar.gz

sudo mkdir -p $MAVEN_DIR
sudo tar -xvzf ~/apache-maven-$MAVEN_VERSION-bin.tar.gz -C $MAVEN_DIR

sudo ln -s $MAVEN_DIR/apache-maven-$MAVEN_VERSION /opt/maven/maven-$MAVEN_VERSION
sudo ln -s /opt/maven/maven-$MAVEN_VERSION/bin/mvn /usr/bin/mvn-$MAVEN_VERSION

# checking command:
mvn-3.9.9 --version

# Apache Maven 3.9.9 (8e8579a9e76f7d015ee5ec7bfcdc97d260186937)
# Maven home: /opt/maven/maven-3.9.9
# Java version: 17.0.12, vendor: Amazon.com Inc., runtime: /usr/lib/jvm/java-17-amazon-corretto.x86_64
# Default locale: en_US, platform encoding: UTF-8
# OS name: "linux", version: "4.14.352-267.564.amzn2.x86_64", arch: "amd64", family: "unix"
```


## III. Maven command:

### step-1: clone the repository with `git`
```powershell
git clone https://github.com/duongdx-kma/first-demo-project.
```

### step-2: Validate the project with `maven`
```powershell
# change directory
cd first-demo-project

# command:
mvn validate

# result:
[INFO] Scanning for projects...
[INFO] 
[INFO] -----------------< com.democompany:first-demo-project >-----------------
[INFO] Building first-demo-project 0.0.1-SNAPSHOT
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  0.075 s
[INFO] Finished at: 2024-09-13T16:48:16Z
```

### step-3: compile code with `maven`:
```powershell
# command:
mvn compile

# result:

Downloaded from central: https://repo.maven.apache.org/maven2/com/thoughtworks/qdox/qdox/2.0-M9/qdox-2.0-M9.jar (317 kB at 20 MB/s)
...........................................
Downloaded from central: https://repo.maven.apache.org/maven2/org/codehaus/plexus/plexus-compiler-api/2.8.4/plexus-compiler-api-2.8.4.jar (27 kB at 1.4 MB/s)
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 1 source file to /home/ec2-user/first-demo-project/target/classes
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  2.990 s
[INFO] Finished at: 2024-09-13T16:50:37Z
[INFO] ------------------------------------------------------------------------

# check JAR result

```

### step-4: Running test into test-directory with `maven`:
```powershell
# command:
mvn test-compile


# result:
[INFO] Scanning for projects...
[INFO] 
[INFO] -----------------< com.democompany:first-demo-project >-----------------
[INFO] Building first-demo-project 0.0.1-SNAPSHOT
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------

...------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  1.845 s
[INFO] Finished at: 2024-09-13T16:58:27Z
[INFO] ------------------------------------------------------------------------
```

### step-5: check project structure:
```powershell
.
├── pom.xml
├── src
│   ├── main
│   │   └── java
│   │       └── com
│   │           └── democompany
│   │               └── first_demo_project
│   │                   └── App.java
│   └── test
│       └── java
│           └── com
│               └── democompany
│                   └── first_demo_project
│                       └── AppTest.java
└── target
    ├── classes
    │   └── com
    │       └── democompany
    │           └── first_demo_project
    │               └── App.class
    ├── generated-sources
    │   └── annotations
    ├── generated-test-sources
    │   └── test-annotations
    ├── maven-status
    │   └── maven-compiler-plugin
    │       ├── compile
    │       │   └── default-compile
    │       │       ├── createdFiles.lst
    │       │       └── inputFiles.lst
    │       └── testCompile
    │           └── default-testCompile
    │               ├── createdFiles.lst
    │               └── inputFiles.lst
    └── test-classes
        └── com
            └── democompany
                └── first_demo_project
                    └── AppTest.class
```