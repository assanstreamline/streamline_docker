library(googleCloudRunner)
library(trailrun)
setup = cr_gce_setup()
source("cr_helpers.R")
source("docker_functions.R")
# # need this because otherwise recursive copying


location = "us"
pre_steps = c(
  cr_buildstep_docker_auth(location)
  # setup_streamline_scripts("ssh-deploy-key")
)

result = cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner-shinyvm",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_shinyvm",
  timeout = 3600L,
  pre_steps = pre_steps,
  kaniko_cache = FALSE
)
