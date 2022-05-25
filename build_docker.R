library(googleCloudRunner) # R library to interact with gcp
library(trailrun) #
source("cr_helpers.R") # helper functions :
source("docker_functions.R") # docker functions : (missing startup scripts?)
setup = cr_gce_setup()
options("googleAuthR.verbose" = 3)
# # need this because otherwise recursive copying

file.remove("~/streamline_docker/Dockerfile")  #remove Dockerfile

location = c("us", "us-docker.pkg.dev", 
             "us-east4-docker.pkg.dev",
             "gcr.io", "us.gcr.io") #location of the image  -- not used 
# pre_steps = c(
#   # setup_streamline_scripts()
#   # cr_buildstep_docker_auth(location),
#   # cr_buildstep(
#   #   "cloud-sdk:latest",
#   #   entrypoint = "gcloud",
#   #   args = c("beta", "auth", "configure-docker",
#   #            "us-docker.pkg.dev"),
#   #   prefix = "gcr.io/google.com/cloudsdktool/"
#   # ),
#   # cr_buildstep_cat("~/.docker/config.json"), 
#   googleCloudRunner::cr_buildstep_gitsetup("ssh-deploy-key")
# )
pre_steps = NULL
pre_steps = c(pre_steps,
              setup_streamline_scripts("ssh-deploy-key")) # preliminary step : using the ssh key for deployment


# file.remove("~/streamline_docker/Dockerfile")
# cr_deploy_docker(
#   local = "~/streamline_docker",
#   image_name = paste0("us-docker.pkg.dev/streamline-resources/",
#                       "streamline-private-repo/streamliner"),
#   dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_streamliner",
#   pre_steps = pre_steps,
#   kaniko_cache = FALSE,
#   timeout = 3600L
# )

image_url = paste0("us-docker.pkg.dev/streamline-resources/",
                   "streamline-private-repo/streamliner-packages") # Docker image url
pre_steps = c(pre_steps,
              cr_buildstep_bash(
                paste0("mkdir -p /workspace/.ssh && ",
                       "cp /root/.ssh/* /workspace/.ssh/"),
                volumes = git_volume(),
                id = "cp deploy ssh"
              )
) # add first steps (ssh key related)
cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = image_url,
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_packages",
  pre_steps = pre_steps,
  kaniko_cache = FALSE,
  volumes = git_volume(),
  # images = image_url,
  timeout = 3600L
) # cloud runner command to deploy the image based on the dockerfile accessible on private github repo/folder

# https://gcr.io/streamline-resources/streamline-docker-repo/streamliner-packages




# file.remove("~/streamline_docker/Dockerfile")
# location = "us"
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
#   cr_buildstep_docker_auth(location),
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
