library(googleCloudRunner)
library(trailrun)
source("cr_helpers.R")
source("docker_functions.R")
setup = cr_gce_setup()
options("googleAuthR.verbose" = 3)
# # need this because otherwise recursive copying


make_character_vector = function(x) {
  stopifnot(!any(grepl("'", x)))
  x = paste0("'", x, "'")
  x = paste0(x, collapse = ", ")
  x = paste0("c(", x, ")")
  x
}

collapse_package_install = function(x,
                                    git = c("auto", "git2r", "external")
) {
  git = match.arg(git)
  type = "git"
  x = sapply(x, function(pkgs) {
    cmds = paste0("remotes::install_", type)
    pkgs = make_character_vector(pkgs)
    add_git = paste0(", git = '", git, "'")
    
    cmd = paste0('R -e "',
                 paste0(cmds, "(", pkgs, add_git, ")"), '"')
    containerit::Run_shell(cmd)
    
  })
  x
}

ssh = trailrun::docker_setup_ssh()
docker_instructions = c(
  containerit::Copy("check_remotes_version.R", "/"),
  containerit::CMD_Rscript(path = "/check_remotes_version.R"),
  ssh$pre_steps,
  collapse_package_install(
    c("git@github.com:StreamlineDataScience/metagce",
      "git@github.com:StreamlineDataScience/gcloud",
      "git@github.com:StreamlineDataScience/trailrun",
      "git@github.com:StreamlineDataScience/streamliner",
      "git@github.com:StreamlineDataScience/streamverse"
    ), git = "external"),
  ssh$post_steps
)

image_url = paste0("us-docker.pkg.dev/streamline-resources/", 
                   "streamline-private-repo/streamliner:latest")
dockerfile = containerit::dockerfile(
  from = containerit::clean_session(),
  instructions = docker_instructions,
  image = image_url, 
  container_workdir = "./",
  cmd = "/init")
containerit::write(dockerfile, 
                   file = "dockerfiles/Dockerfile_packages")



file.remove("~/streamline_docker/Dockerfile")

build_ssh = trailrun::build_setup_ssh()

location = c("us", "us-docker.pkg.dev",
             "us-east4-docker.pkg.dev",
             "gcr.io", "us.gcr.io")
pre_steps = c(
  cr_buildstep_cat("Dockerfile"),
  googleCloudRunner::cr_buildstep_gitsetup("ssh-deploy-key"),
  build_ssh$pre_steps
)


result = cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = paste0("us-docker.pkg.dev/streamline-resources/", 
                      "streamline-private-repo/streamliner-packages"),
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_packages",
  timeout = 3600L,
  pre_steps = pre_steps,
  post_steps = build_ssh$post_steps,
  volumes = git_volume(),
  kaniko_cache = FALSE
)
