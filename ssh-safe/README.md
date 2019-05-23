# SSH Tool

## Grabs SSH key from AWS Secrets Manager

Usage:

Pull file down to your computer and update with desired profile and secret name stored in AWS Secrets Manager along with the right region.

Make file executable:<br>
`chmod +x ssh-tools.sh`

Run command with this syntax:<br>

`ssh-tools.sh username ip-address`<br>

replacing username and ip-address with the user and IP for the instance you are attempting to access.