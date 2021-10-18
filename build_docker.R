library(googleCloudRunner)
library(trailrun)
setup = cr_gce_setup()
options("googleAuthR.verbose" = 3)
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
  cr_buildstep_docker_auth_location(location),
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



# file.remove("~/streamline_docker/Dockerfile")
# location = "us-east4"
# cp_step = cr_buildstep_bash(
#   paste0("mkdir -p /workspace/deploy/.ssh && ", 
#          "cp /root/.ssh/* /workspace/deploy/.ssh/"),
#   volumes = git_volume(),
#   id = "cp deploy ssh"
# )
# rm_step = cr_buildstep_bash(
#   "rm -rf /workspace/deploy/.ssh",
#   id = "rm deploy ssh"
# )
# pre_steps = c(
#   cr_buildstep_docker_auth_location(location),
#   cr_buildstep_gitsetup("ssh-deploy-key"),
#   cp_step
# )
# post_steps = c(rm_step)
# 
# result = cr_deploy_docker(
#   local = "~/streamline_docker",
#   image_name = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner-remotes-packages",
#   dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_remotes_packages",
#   timeout = 3600L,
#   pre_steps = pre_steps,
#   post_steps = post_steps,
#   kaniko_cache = FALSE,
#   push_image = FALSE,
#   # build_args = c("--ssh", "default=/root/.ssh/id_rsa"),
#   # volumes = git_volume()
# )
