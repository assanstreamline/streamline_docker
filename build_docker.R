library(googleCloudRunner)
# need this because otherwise recursive copying
owd = getwd()
tdir = tempdir()
setwd(tdir) 

cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "streamline-docker-repo/streamliner",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_streamliner",
  timeout = 3600L
)
setwd(owd)
