### Description

This is an AWS SAM project for searching DocBase memo via Slack commands.

### How to deploy

```
# A S3 Bucket which stores CFn templates
export S3_BUCKET_NAME=
# SAM stack name
export CFN_STACK_NAME=

export DOCBASE_DOMAIN=
export DOCBASE_TOKEN=
export SLACK_TOKEN=

./deploy.sh
```
