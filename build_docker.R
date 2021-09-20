library(googleCloudRunner)
source("cr_helpers.R")
setup = cr_gce_setup()

# # need this because otherwise recursive copying
# owd = getwd()
# tdir = setwd("~/")
# 
# file.remove("~/streamline_docker/Dockerfile")
# cr_deploy_docker(
#   local = "~/streamline_docker",
#   image_name = "streamline-docker-repo/streamliner",
#   dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_streamliner",
#   timeout = 3600L
# )
# setwd(owd)


# If you need GH keys:
pre_steps = c(
  cr_buildstep_gitsetup("ssh-deploy-key", type = "ed25519")
)
result = cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "streamline-docker-repo/streamliner-packages",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_packages",
  timeout = 3600L,
  tag = "latest",
  pre_steps = pre_steps,
  volume = git_volume()
)
