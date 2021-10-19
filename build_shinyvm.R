library(googleCloudRunner)
library(trailrun)
source("cr_helpers.R")
setup = cr_gce_setup()
options("googleAuthR.verbose" = 3)
image = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner-packages"
pre_steps = c(
  cr_buildstep_docker_auth_location(c("us-east4", "us")),
  cr_buildstep(
    id = "My docker pull",
    name = "docker",
    args = c("pull",
             image)
  )
)


result = cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner-shinyvm",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_shinyvm",
  timeout = 3600L,
  pre_steps = pre_steps,
  kaniko_cache = FALSE
)
