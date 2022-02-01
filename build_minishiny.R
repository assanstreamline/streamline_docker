library(googleCloudRunner)
library(trailrun)
source("cr_helpers.R")
setup = cr_gce_setup()
options("googleAuthR.verbose" = 3)

file.remove("~/streamline_docker/Dockerfile")
location = c("us-east4", "us")
pre_steps = c(
  cr_buildstep_docker_auth(location),
  cr_buildstep_gitsetup("ssh-deploy-key"),
  cr_buildstep_git_packages(
    path = "/workspace/packages",
    repos = c("git@github.com:StreamlineDataScience/gcloud",
              "git@github.com:StreamlineDataScience/metagce")
  )
)


result = cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = "us-docker.pkg.dev/streamline-resources/streamline-private-repo/streamliner-mini-shinyvm",
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_minishinyvm",
  timeout = 3600L,
  pre_steps = pre_steps,
  kaniko_cache = FALSE
)

result$steps

