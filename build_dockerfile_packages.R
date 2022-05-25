library(googleCloudRunner)
library(trailrun)
source("cr_helpers.R")
source("docker_functions.R")
setup = cr_gce_setup() #from the helpers functions
options("googleAuthR.verbose" = 3)
# # need this because otherwise recursive copying


make_character_vector = function(x) {
  stopifnot(!any(grepl("'", x))) # does not run if a character already has '
  x = paste0("'", x, "'") #append ' to charact
  x = paste0(x, collapse = ", ") #remove/squash the ", "
  x = paste0("c(", x, ")")
  x
}

collapse_package_install = function(x,
                                    git = c("auto", "git2r", "external")
) {
  git = match.arg(git) #match an element in the list above
  type = "git"
  x = sapply(x, function(pkgs) {
    cmds = paste0("remotes::install_", type) # "remotes::install_"git
    pkgs = make_character_vector(pkgs) #transform the list of packages in a string
    add_git = paste0(", git = '", git, "'") #' git = external ' (for exemple)
    
    cmd = paste0('R -e "',
                 paste0(cmds, "(", pkgs, add_git, ")"), '"')
    containerit::Run_shell(cmd) # execute the neo formed shell command
    
  })
  x # command line executed based on concatenation above - returns the value of x
}

ssh = trailrun::docker_setup_ssh() # ssh steup (see trailrun)
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
) # docker instructions  (2 .R scripts, init ssh, install of packages and ssh final steps)

image_url = paste0("us-docker.pkg.dev/streamline-resources/", 
                   "streamline-private-repo/streamliner:latest") # selection of the docker image
dockerfile = containerit::dockerfile(
  from = containerit::clean_session(),
  instructions = docker_instructions,
  image = image_url, 
  container_workdir = "./",
  cmd = "/init") # create a dockerfile from above instructions
containerit::write(dockerfile, 
                   file = "dockerfiles/Dockerfile_packages") #write the dockerfile to disk



file.remove("~/streamline_docker/Dockerfile") #why?

build_ssh = trailrun::build_setup_ssh("/workspace") 

location = c("us", "us-docker.pkg.dev",
             "us-east4-docker.pkg.dev",
             "gcr.io", "us.gcr.io")
pre_steps = c(
  cr_buildstep_cat("Dockerfile"),
  googleCloudRunner::cr_buildstep_gitsetup("ssh-deploy-key"),#Create a build step for authenticating with Git (key must be in Google Secrets Manager)
  build_ssh$pre_steps
)






result = cr_deploy_docker(
  local = "~/streamline_docker",
  image_name = paste0("us-docker.pkg.dev/streamline-resources/", 
                      "streamline-private-repo/streamliner-packages"), #The image tag that will be pushed
  dockerfile = "~/streamline_docker/dockerfiles/Dockerfile_packages", #Path to Dockerfile
  timeout = 3600L,
  pre_steps = pre_steps,
  post_steps = build_ssh$post_steps,
  volumes = git_volume(),
  kaniko_cache = FALSE
) #build docker image based on the Dockerfile created above 
