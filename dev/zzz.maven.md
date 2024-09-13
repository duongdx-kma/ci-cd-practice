### Maven Default Lifecycle

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