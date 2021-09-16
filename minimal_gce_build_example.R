# Sys.setenv(GAR_CLIENT_JSON = "~/streamline-demo/auths/client.json")
# Sys.setenv(GAR_AUTH_FILE = "~/streamline-demo/download/service_account.json")
# Sys.setenv(GCE_AUTH_FILE = Sys.getenv("GAR_AUTH_FILE"))


# cr_email_set
library(googleCloudRunner)
source("cr_helpers.R")

# Private keys/auth
# https://cloud.google.com/iam/docs/creating-managing-service-account-keys#getting_a_service_account_key
# You can only get the private key data for a service account key when the key is first created.

cr_gce_setup()
files = c("blah.txt")
steps = cr_buildstep_touch(files, bash_source = "local")
build = cr_build_yaml(steps)
run = cr_build(build)



