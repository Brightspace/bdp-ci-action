#!/bin/sh

set -eu

projectPath=$1
deploy=$2
productBranch=$3
productBuildNumber=$4
codeCoverageCommands=$5

echo " \n\n === Building .jar file === \n"

# print maven's version
mvn --version

# setup CodeArtifact access token for Maven
mkdir -p ~/.m2
echo '
  <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <profiles>
      <profile>
        <id>d2l-private</id>
        <activation>
          <activeByDefault>true</activeByDefault>
        </activation>
        <repositories>
          <repository>
            <id>d2l-private</id>
            <url>https://d2l-569998014834.d.codeartifact.us-east-1.amazonaws.com/maven/private/</url>
          </repository>
        </repositories>
      </profile>
    </profiles>
    <servers>
      <server>
        <id>d2l-private</id>
        <username>aws</username>
        <password>${env.CODEARTIFACT_AUTH_TOKEN}</password>
      </server>
    </servers>
  </settings>' > ~/.m2/settings.xml

# check if in root directory
if [ ! -d ".git" ]; then
  echo "You must be in the project's root!\n"
  exit 1
fi

# build Spark jar
echo " \n\n === Maven build === \n"
cd $projectPath
export COVERALLS_PARALLEL=true
export CI_NAME=Github
export CI_BUILD_NUMBER=$GITHUB_RUN_ID
mvn -s ~/.m2/settings.xml verify $codeCoverageCommands

# exit script if deploy is false
if [ $deploy = "false" ]; then
  exit 0
fi

# deploy to CodeArtifact
if [ -z $productBuildNumber ]; then
  # get the package version from the pom.xml
  # add following to pom.xml
  # <plugin>
  #    <groupId>org.apache.maven.plugins</groupId>
  #    <artifactId>maven-help-plugin</artifactId>
  #    <version>3.2.0+</version>
  # </plugin>
  packageVersion=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
else
  packageVersion="1.0.$productBuildNumber"
fi

# deploy to CodeArtifact only on master or if a dev wants to force a dev branch to build
if ([ ! -z $productBranch ] && [ $productBranch = "master" ]) || [ $deploy = "force" ]; then
  echo "deploying version: '$packageVersion'"
  echo "\n ==> Deploy to CodeArtifact \n"

  mvn -s ~/.m2/settings.xml -f pom.xml "-DnewVersion=$packageVersion" versions:set
  mvn -s ~/.m2/settings.xml -f pom.xml install deploy
fi
