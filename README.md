# bdp-ci-action
Github actions for BDP CI


## java-build
- If DEPLOY="true" is set on a component's CI then this script only releases commits to master to Artifactory.
If a developer needs to publish a development build simply change the component CI to use DEPLOY="force" on the development branch.

- By default the java-build will assume that both Jacoco and Coveralls are enabled plugins. You can overwrite
the coverage directives with `CODE_COVERAGE_COMMANDS=<custom commands>`. An empty string disables code coverage.

### Read-only Access

Regardless of whether you have write access to any particular packages, you can get read-only access to all packages in your workflow:

```yaml
jobs:
  build:
    # ...
    steps:
      # ...
      - name: Build jar
        uses: Brightspace/bdp-ci-action/java-build@master
        with:
          AUTH_TOKEN: ${{ secrets.CODEARTIFACT_AUTH_TOKEN }}
          PROJECT_PATH: "."
          DEPLOY: "true"
          BRANCH: ${{ steps.get_branch_and_build.outputs.branch }}
          BUILDNUM: ""
      # ...
```

### Publishing a Maven package

To publish new versions of your package you will need to get an authorization token first:

```yaml
jobs:
  build:
    # ...
    steps:
      # ...
      - name: Get CodeArtifact token
        uses: Brightspace/codeartifact-actions/get-authorization-token@main
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_SESSION_TOKEN: ${{ secrets.AWS_SESSION_TOKEN }}

      - name: Build jar
        uses: Brightspace/bdp-ci-action/java-build@master
        with:
          AUTH_TOKEN: ${{ env.CODEARTIFACT_AUTH_TOKEN }}
          PROJECT_PATH: "."
          DEPLOY: "true"
          BRANCH: ${{ steps.get_branch_and_build.outputs.branch }}
          BUILDNUM: ""
      # ...
```
