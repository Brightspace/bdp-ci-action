# Upload Artifacts javascript action

This action pack the artifacts and upload to AWS S3 and output a URL for access.

## Inputs

### `s3-bucket`

**Required** The AWS S3 bucket that artifacts upload to.

### `artifacts-path`

**Required** The path of the artifacts directory. Default: artifacts

## Example usage

```
- name: Set up AWS creds
	uses: Brightspace/third-party-actions@aws-actions/configure-aws-credentials
	with:
		aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
		aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
		aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
		aws-region: us-east-1
		role-to-assume: "arn:aws:iam::728041832160:role/bdp-ci-github"
		role-duration-seconds: 1200
...
- name: Upload Artifacts
	if: always() # This ensures the artifacts get uploaded even if previous step fails
	uses: Brightspace/bdp-ci-action/upload-artifacts@master
	with:
		s3-bucket: timbai-github-artifacts
```
