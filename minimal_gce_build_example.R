library(googleCloudRunner)
source("cr_helpers.R")

# This must be run on GCE, which uses the metadata server to setup all
# the build 
setup = cr_gce_setup()
files = c("blah.txt")
steps = cr_buildstep_bash("ls /workspace")
build = cr_build_yaml(steps)
run = cr_build(build)
