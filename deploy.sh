#!/bin/sh

if [ "${S3_BUCKET_NAME}" = "" ]; then
  echo "'S3_BUCKET_NAME' should be specified as an environment variable." 1>&2
  exit 1
fi
if [ "${CFN_STACK_NAME}" = "" ]; then
  echo "'CFN_STACK_NAME' should be specified as an environment variable." 1>&2
  exit 1
fi
if [ "${DOCBASE_DOMAIN}" = "" ]; then
  echo "'DOCBASE_DOMAIN' should be specified as an environment variable." 1>&2
  exit 1
fi
if [ "${DOCBASE_TOKEN}" = "" ]; then
  echo "'DOCBASE_TOKEN' should be specified as an environment variable." 1>&2
  exit 1
fi
if [ "${SLACK_TOKEN}" = "" ]; then
  echo "'SLACK_TOKEN' should be specified as an environment variable." 1>&2
  exit 1
fi

cat << EOT

[ Environment variables ]

S3_BUCKET_NAME: ${S3_BUCKET_NAME}
CFN_STACK_NAME: ${CFN_STACK_NAME}

DOCBASE_DOMAIN: ${DOCBASE_DOMAIN}
DOCBASE_TOKEN:  *******
SLACK_TOKEN:    *******

EOT

aws cloudformation package --template-file template.yaml \
    --output-template-file serverless-output.yaml --s3-bucket ${S3_BUCKET_NAME}

aws cloudformation deploy --stack-name ${CFN_STACK_NAME} \
    --template-file serverless-output.yaml \
    --parameter DocBaseDomain=${DOCBASE_DOMAIN} \
                DocBaseToken=${DOCBASE_TOKEN} \
                SlackToken=${SLACK_TOKEN} \
    --capabilities CAPABILITY_IAM

URL=$( aws cloudformation describe-stacks --stack-name ${CFN_STACK_NAME} \
    --query 'Stacks[].Outputs[?OutputKey==`URL`].OutputValue' --output text )
cat << EOT

[ The endpoint base URL ]

${URL}

EOT
