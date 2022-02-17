library(trailrun)
library(dplyr)
library(containerit)
library(googleCloudRunner)
source("docker_functions.R")

trailrun::cr_gce_setup()

r_ver = trailrun::rocker_versions() %>% 
  filter(base_image %in% "r-ver") %>% 
  mutate(full_image = paste0("rocker/", image))

from = containerit::clean_session()

dock = trailrun::docker_setup_ssh()

ports = c(8888, 8787, 3838)
docker_instructions = NULL
# expose the port for the app
docker_instructions = c(
  docker_instructions,
  containerit::Run_shell("/rocker_scripts/install_pandoc.sh"),  
  sapply(ports, function(port) containerit::Expose(port = port))
)

docker_instructions = c(
  docker_instructions,
  containerit::Run_shell("chmod 755 .")
)

# docker_instructions = c(
#   docker_instructions,
#   dock$pre_steps
# )


docker_instructions = c(
  docker_instructions,
  containerit::Copy("streamline_startup_scripts/scripts",
                    "/streamline_scripts", 
                    addTrailingSlashes = FALSE),
  containerit::Run_shell("chmod +x /streamline_scripts/*.sh"),
  containerit::Run_shell("/streamline_scripts/install_3rd_party.sh"),
  containerit::Run_shell("/streamline_scripts/install_3rd_party_extensions.sh"),
  containerit::Run_shell("/streamline_scripts/install_texlive.sh"),
  containerit::Run_shell("/streamline_scripts/install_odbc_drivers.sh"),
  containerit::Run_shell("/streamline_scripts/install_gcloud.sh"),
  containerit::Run_shell("install2.r --error renv remotes rcmdcheck")
)

docker_instructions = c(
  docker_instructions,
  containerit::Env("_R_CHECK_CRAN_INCOMING_", "false"), 
  containerit::Copy("package_scripts", "/package_scripts", 
                    addTrailingSlashes = FALSE),
  containerit::Run_shell("chmod +x /package_scripts/*"),
  containerit::Run_shell("R -f /package_scripts/remotes_external_git.R")
)

## Install packages from CRAN
#    googleAuthR \ 

# docker_instructions = c(
#   docker_instructions,
#   dock$post_steps)
r_ver = r_ver %>% 
  filter(grepl("^4[.]1.*", version))
index = 2
# for (index in seq(nrow(r_ver))) {
image = r_ver$full_image[index]
image_basename = "renv-base"
tag = r_ver$version[index]
image_name = paste0(image_basename, ":", tag)
dockerfile_name = paste0(image_basename, "_", r_ver$version[index])
dockerfile_name = paste0("dockerfiles/Dockerfile_", image_name)

result = containerit::dockerfile(
  maintainer = "Streamline_Data_Science",
  from = from,
  image = image,
  offline = TRUE,
  cmd = NULL,
  container_workdir = "./",
  instructions = docker_instructions,
  platform = "linux-x86_64-ubuntu-gcc"
)
containerit::write(result, file = dockerfile_name)
# }

image_url = paste0(
  "us-docker.pkg.dev/streamline-resources/", 
  "streamline-private-repo/", 
  image_basename,
  "-", tag)
pre_steps = c(
  cr_buildstep_docker_auth(image_url),
  setup_streamline_scripts("ssh-deploy-key")
)
build2 = function(image_name, ...) {
  # tag = c("latest", "$BUILD")
  build_args = c("--cache-from", paste0(image_name, ":latest"))
  googleCloudRunner::cr_deploy_docker(
    ...,
    image_name = image_name,
    timeout = 3600L,
    images = image_name,
    build_args = build_args,
    kaniko_cache = FALSE,
    # options = list(machineType = "N1_HIGHCPU_8"),
    volumes = googleCloudRunner::git_volume(),
  )
}

result = build2(
  local = "~/streamline_docker",
  image_name = image_url,
  dockerfile = dockerfile_name,
  pre_steps = pre_steps,
  launch_browser = FALSE
)

# }
