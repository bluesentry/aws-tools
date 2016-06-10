# aws-tools
Open-sourced tooling developed by BSI staff for project work

## IAM

### aws-ca-creds-update.sh

Set cross-account credentials in your `.aws/credentials` file when MFA tokens are required.  This makes it less cumbersome to do long-running operations from the CLI (or from a script).

In order to use this script, you will need the [AWS command-line tools package](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) installed as well as the [jq utility](https://stedolan.github.io/jq/).  If the script detects that either of these is not in the path, it will error out when run.

Usage:
`aws-ca-creds-update.sh -t='tokenserial' -b='baseawsprofilename' -u='updateawsprofilename' -r='assumerolearn' -s='sessionname' -v=tokenval`
  
  * `tokenserial` is the serial number for the token.  It can be found in your IAM settings if you're using a software-based token like Google Authenticator.
  * The profile names are the section identifiers for the profiles in question within your .aws/credentials file.  "Base" is the account you use to do the passthrough.  "Update" is the account you're passing into.
  * `assumerolearn` is the ARN of the role you're assuming in the target account.
  * `sessionname` uniquely identifies the session.
  * `tokenval` is the value of the token for the base profile at the time you invoke the script.

Credentials are good for one hour.
No output means the operation was successful.