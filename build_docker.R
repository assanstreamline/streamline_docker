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
#   # image_name = "streamline-docker-repo/streamliner",
#   image_name = "us-east4-docker.pkg.dev/streamline-resources/streamline-docker-repo/streamliner",
#   dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_streamliner",
#   kaniko_cache = FALSE,
#   timeout = 3600L
# )
# setwd(owd)



# If you need GH keys:
file.remove("~/streamline_docker/Dockerfile")
location = "us-east4"
pre_steps = c(
  cr_buildstep_docker_auth(location),
  cr_buildstep_gitsetup("ssh-deploy-key"),
  cr_buildstep_git_packages(
    path = "/workspace/deploy/packages",
    repos = c("StreamlineDataScience/gcloud",
              "StreamlineDataScience/metagce")
  )
) 



result = cr_deploy_docker(
  local = "~/streamline_docker",
  # image_name = "streamline-docker-repo/streamliner-packages",
  image_name = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner-packages",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_packages",
  timeout = 3600L,
  pre_steps = pre_steps,
  kaniko_cache = FALSE,
  # build_args = c("--ssh", "default=/root/.ssh/id_rsa"),
  volumes = git_volume()
)
# https://gcr.io/streamline-resources/streamline-docker-repo/streamliner-packages

