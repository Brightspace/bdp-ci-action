#!/bin/sh

set -eu

accessToken=$1
projectPath=$2
deploy=$3
productBranch=$4
productBuildNumber=$5

echo " \n\n === Building .jar file === \n"

# print maven's version
mvn --version

# setup Artifactory access token for Maven
mkdir -p ~/.m2
echo $accessToken > ~/.m2/settings.xml

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
mvn -s ~/.m2/settings.xml verify jacoco:report coveralls:report

# exit script if deploy is false
if [ $deploy = false ]; then
  exit 0
fi

# deploy to Artifactory
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

# deploy to Artifactory only on master
if [ ! -z $productBranch ] && [ $productBranch = "master" ]; then
  echo "deploying version: '$packageVersion'"
  echo "\n ==> Deploy to Artifactory \n"

  mvn -s ~/.m2/settings.xml -f pom.xml "-DnewVersion=$packageVersion" versions:set
  mvn -s ~/.m2/settings.xml -f pom.xml install deploy
fi
