Automation commands shared between all Agron data collection microservices.

## Configuration
- Copy `makefile` contents into `inc.Makefile.mk` in your repository's root directory
- Add `inc.Variables.mk` in root directory, define the following variables:
  - NAME
  - PORT
  - AWS_ID (defaults to 203976053147)
  - AWS_REGION (defaults to eu-west-1)
- Add a `makefile` to your repository and include `inc.Makefile.mk` in it with `include inc.Makefile.mk`

***
DO NOT UPDATE `inc.Makefile.mk` FILE DIRECTLY FROM YOUR REPOSITORY. Add additional commands to your repository's `makefile` or make a pull request to this repository and then run `make build-tools` in yours.
