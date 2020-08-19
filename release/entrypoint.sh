#!/bin/sh

set -eu

echo " \n\n === Staging Product For Release === \n"

gitBranch=$([[ -z "$GITHUB_HEAD_REF" ]] && echo "$GITHUB_REF" || echo "$GITHUB_HEAD_REF")
buildNum=$(($GITHUB_RUN_NUMBER + $BUILD_NUM_OFFSET))
echo "::set-output name=branch::${gitBranch##refs/heads/}"
echo "::set-output name=build::${buildNum}"

# Install git if not exist
if ! command -v git &> /dev/null; then
    echo " \n ==> Installing Git \n"
    apt update && apt upgrade -y && apt install git -y
fi

# Check if in root directory
if [ ! -d ".git" ]; then
  echo "You must be in the projects root!\n"
  exit 1
fi

echo " \n ==> Clean Existing Folders \n"
git clean -fxd -e mocha.xml -e coverage/ -e spark/ -e *.jar

echo " \n ==> Creating Git Revision File \n"
mkdir -p release/
revision=`git rev-parse HEAD`
revisionUrl=`git config remote.origin.url`
echo "[$revision] $revisionUrl"
echo "$revisionUrl,$revision" >> release/git_revisions.csv

if [ -z $gitBranch ]; then
  gitBranch=`git rev-parse --abbrev-ref HEAD`
fi
if [ $gitBranch = "master" ]; then
  echo " \n ==> Creating Git History File \n"
  # hash, author name, author email, commit message
  git --no-pager log --oneline --format='%H,"%an","%ae","%s"' > release/git_history.csv
fi

echo " \n ==> Stage \n"
mkdir -p release/install/
git ls-files |
  egrep -v '^\.' |
  egrep -v '/\.' |
  egrep -v '^bdp-ci' |
  egrep -v '^spark/' |
  egrep -v '^handlers/' |
  xargs -I{} cp --parents -Rv {} release/install/

# Take care of serverless plugins
if [ -d ".serverless_plugins" ]; then
  cp -Rv .serverless_plugins release/install/.serverless_plugins
fi

# Take care of spark jar
if [ -d "spark" ]; then
  echo " \n ==> Stage Spark jar \n"
  mkdir -p release/install/spark/target
  rm -v spark/target/original-*.jar
  cp -v spark/target/*.jar release/install/spark/target/
fi

# Take care of bdp-config
if [ -d "configs" ]; then
  echo " \n ==> Stage Configs \n"
  mv -v release/install/configs release/
fi

if [ -d "install" ]; then
  mv -v release/install/install/* release/install/
  rm -rv release/install/install/
fi

# Create tarball
echo " \n ==> Creating tarball \n"
tar -C ./release -czvf release.tar.gz .

# Generate version file
echo " \n ==> Write version file \n"
echo $buildNum > latestBuild
