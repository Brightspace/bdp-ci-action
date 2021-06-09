# bdp-ci-action
Github actions for BDP CI


## java-build
- If DEPLOY="true" is set on a component's CI then this script only releases commits to master to Artifactory.
If a developer needs to publish a development build simply change the component CI to use DEPLOY="force" on the development branch.

- By default the java-build will assume that both Jacoco and Coveralls are enabled plugins. You can overwrite
the coverage directives with `CODE_COVERAGE_COMMANDS=<custom commands>`. An empty string disables code coverage.
