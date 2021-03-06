### Swagger Codegen 3.0.0 Standalone generator development (separate project/repo)

As described in [Readme](https://github.com/swagger-api/swagger-codegen/tree/3.0.0#making-your-own-codegen-modules),
a new generator can be implemented by starting with a project stub generated by the `meta` command of `swagger-codegen-cli`.

This can be achieved without needing to clone the `swagger-codegen` repo, by downloading and running the jar, e.g.:

```
wget https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.21/swagger-codegen-cli-3.0.21.jar -O swagger-codegen-cli.jar
java -jar swagger-codegen-cli.jar meta -o output/myLibrary -n myClientCodegen -p com.my.company.codegen
```

Some additional details about codegen APIs of interest to the generator Java class(es) are [available here](https://github.com/swagger-api/swagger-codegen-generators/wiki/Adding-a-new-generator-for-a-language-or-framework.
).

Such generator can be then made available to the CLI by adding it to the classpath, allowing to run/test it via the command line CLI,
add it to the build pipeline and so on, as mentioned in [Readme](https://github.com/swagger-api/swagger-codegen/tree/3.0.0#making-your-own-codegen-modules).

#### Adding tests

One easy way to test the generator outcome without going through the CLI is adding a test like:


```java

@Test
public void testGenerator() throws Exception {

    String path = getOutFolder(false).getAbsolutePath();
    GenerationRequest request = new GenerationRequest();
    request
        .codegenVersion(GenerationRequest.CodegenVersion.V3) // use V2 to target Swagger/OpenAPI 2.x Codegen version
        .type(GenerationRequest.Type.CLIENT)
        .lang("theNameOfMyCodegen")
        .spec(loadSpecAsNode(   "theSpecIWantToTest.yaml",
                                true, // YAML file, use false for JSON
                                false)) // OpenAPI 3.x - use true for Swagger/OpenAPI 2.x definitions
        .options(
                new Options()
                        .outputDir(path)
        );

    List<File> files = new GeneratorService().generationRequest(request).generate();
    Assert.assertFalse(files.isEmpty());
    for (File f: files) {
        // test stuff
    }
}

    protected static File getOutFolder(boolean delete) {
        try {
            File outputFolder = new File("customCodegenOut");
            System.out.println(outputFolder.getAbsolutePath());
            if (delete) {
                // delete..
            }
            return outputFolder;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    protected JsonNode loadSpecAsNode(final String file, boolean yaml, boolean v2) {
        InputStream in = null;
        String s = "";
        try {
            in = getClass().getClassLoader().getResourceAsStream(file);
            if (yaml) {
                if (v2) {
                    return Yaml.mapper().readTree(in);
                } else {
                    return io.swagger.v3.core.util.Yaml.mapper().readTree(in);
                }
            }
            if (v2) {
                return Json.mapper().readTree(in);
            }
            return io.swagger.v3.core.util.Json.mapper().readTree(in);
        } catch (Exception e) {
            throw new RuntimeException("could not load file " + file);
        } finally {
            IOUtils.closeQuietly(in);
        }
    }
```

#### Development in docker

Similar to what mentioned in Readme [development in docker section](https://github.com/swagger-api/swagger-codegen/tree/3.0.0#development-in-docker), a standalone generator can be built and run in docker, without need of a java/maven environment on the local machine.

Generate the initial project:

```bash

# project dir
TARGET_DIR=/tmp/codegen/mygenerator
mkdir -p $TARGET_DIR
cd $TARGET_DIR
# generated code location
GENERATED_CODE_DIR=generated
mkdir -p $GENERATED_CODE_DIR
# download desired version
wget https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.21/swagger-codegen-cli-3.0.21.jar -O swagger-codegen-cli.jar
wget https://raw.githubusercontent.com/swagger-api/swagger-codegen/3.0.0/standalone-gen-dev/docker-stub.sh -O docker-stub.sh
wget https://raw.githubusercontent.com/swagger-api/swagger-codegen/3.0.0/standalone-gen-dev/generator-stub-docker.sh -O generator-stub-docker.sh
chmod +x *.sh
# generated initial stub: -p <root package> -n <generator name>
./generator-stub-docker.sh -p io.swagger.codegen.custom -n custom

```

A test definition if we don't have one:

```bash
wget https://raw.githubusercontent.com/swagger-api/swagger-codegen/3.0.0/modules/swagger-codegen/src/test/resources/3_0_0/petstore-simple.yaml -O petstore-simple.yaml
```


Build the generator and run it against a definition (first time will be slower as it needs to download deps)

```bash
wget https://raw.githubusercontent.com/swagger-api/swagger-codegen/3.0.0/standalone-gen-dev/run-in-docker.sh -O run-in-docker.sh
wget https://raw.githubusercontent.com/swagger-api/swagger-codegen/3.0.0/standalone-gen-dev/docker-entrypoint.sh -O docker-entrypoint.sh
chmod +x *.sh
./run-in-docker.sh generate -i petstore-simple.yaml -l custom -o /gen/$GENERATED_CODE_DIR
```


