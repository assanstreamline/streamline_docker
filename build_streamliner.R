library(googleCloudRunner)
library(trailrun)
setup = cr_gce_setup()
options("googleAuthR.verbose" = 3)
file.remove("~/streamline_docker/Dockerfile")
cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "us-east4-docker.pkg.dev/streamline-resources/streamline-docker-repo/streamliner",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_streamliner",
  kaniko_cache = FALSE,
  timeout = 3600L
)
