library(googleCloudRunner)
library(trailrun)
setup = cr_gce_setup()
options("googleAuthR.verbose" = 3)
file.remove("~/streamline_docker/Dockerfile")
cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_streamliner",
  # kaniko_cache = FALSE,
  timeout = 3600L
)


file.remove("~/streamline_docker/Dockerfile")
cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner-dev",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_streamliner_dev",
  # kaniko_cache = FALSE,
  timeout = 3600L
)
