#!/bin/bash

###########################################################
#  aws-ca-creds-update
#  
#  Usage:
#  aws-ca-creds-update.sh -t='tokenserial' -b='baseawsprofilename' \ 
#    -u='updateawsprofilename' -r='assumerolearn' -s='sessionname' \
#    -v=tokenval
#    
#  - tokenserial can be found in your IAM settings if you're
#    using a software token like Google Authenticator.
#  - The profile names are the section identifiers for the profiles
#    in question within your .aws/credentials file.  "Base"
#    is the account you use to do the passthrough.  "Update" is
#    the account you're passing into.
#  - assumerolearn is the ARN of the role you're assuming in the
#    target account.
#  - sessionname uniquely identifies the session.
#
#  Credentials are good for one hour.
#  No output means the operation was successful.
#
#  Written by:
#       Brad Campbell <brad@bluesentryit.com>
#
###########################################################

type jq >/dev/null 2>&1 || { printf >&2 "jq is required for this script, but it's not installed.  Aborting."; exit 1; }
type aws >/dev/null 2>&1 || { printf >&2 "aws is required for this script, but it's not installed.  Aborting."; exit 1; }

mfa_token_val=000000
mfa_token_sn=''
aws_base_profile=''
aws_update_profile=''
role_assume_arn=''
session_name=''
jq_filter='.[].Credentials.AccessKeyId,.[].Credentials.SecretAccessKey,.[].Credentials.SessionToken'

for i in "$@"
do
    case $i in
        -t=*|--token-serial=*)
            mfa_token_sn="${i#*=}"
            shift
        ;;
        -v=*|--token-value=*)
            mfa_token_val="${i#*=}"
            shift
        ;;
        -b=*|--base-profile=*)
            aws_base_profile="${i#*=}"
            shift
        ;;
        -u=*|--update-profile=*)
            aws_update_profile="${i#*=}"
            shift
        ;;
        -r=*|--role_assume_arn=*)
            role_assume_arn="${i#*=}"
            shift
        ;;
        -s=*|--session_name=*)
            session_name="${i#*=}"
            shift
        ;;
        *)
            printf "Unknown option passed.  Aborting.\nUsage is:\n  aws-ca-creds-update.sh -t='tokenserial' -b='baseawsprofilename' \ \n    -u='updateawsprofilename' -r='assumerolearn' -s='sessionname' \ \n    -v=tokenval\n"
            exit 1
        ;;
    esac
done

aws --profile $aws_base_profile sts assume-role --role-arn $role_assume_arn --role-session-name $session_name --token-code $mfa_token_val --serial-number $mfa_token_sn | jq --slurp -r $jq_filter > ./.new-creds
aws --profile $aws_update_profile configure set aws_access_key_id $(sed '1q;d' .new-creds)
aws --profile $aws_update_profile configure set aws_secret_access_key $(sed '2q;d' .new-creds)
aws --profile $aws_update_profile configure set aws_session_token $(sed '3q;d' .new-creds)

rm .new-creds
