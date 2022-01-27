library(trailrun)
library(dplyr)
library(containerit)

r_ver = trailrun::rocker_versions() %>% 
  filter(base_image %in% "r-ver") %>% 
  mutate(full_image = paste0("rocker/", image))

from = containerit::clean_session()

ports = c(8888, 8787, 3838)
docker_instructions = NULL
# expose the port for the app
docker_instructions = c(
  docker_instructions,
  sapply(ports, function(port) containerit::Expose(port = port))
)

docker_instructions = c(
  docker_instructions,
  containerit::Run_shell("chmod 755 .")
)

docker_instructions = c(
  docker_instructions,
  containerit::Copy("scripts", "/streamline_scripts", addTrailingSlashes = FALSE),
  containerit::Run_shell("chmod +x /streamline_scripts/*.sh"),
  containerit::Run_shell("/streamline_scripts/install_3rd_party.sh"),
  containerit::Run_shell("/streamline_scripts/install_3rd_party_extensions.sh"),
  containerit::Run_shell("/streamline_scripts/install_texlive.sh"),
  containerit::Run_shell("/streamline_scripts/install_odbc_drivers.sh"),
  containerit::Run_shell("/streamline_scripts/install_gcloud.sh")
)


index = 1
for (index in seq(nrow(r_ver))) {
  image = r_ver$full_image[index]
  dockerfile_name = paste0("renv-base_", r_ver$version[index])
  dockerfile_name = paste0("dockerfiles/Dockerfile_", dockerfile_name)
  
  result = containerit::dockerfile(
    maintainer = "Streamline_Data_Science",
    from = from,
    image = image,
    offline = TRUE,
    container_workdir = "./",
    instructions = docker_instructions,
    platform = "linux-x86_64-ubuntu-gcc"
  )
  containerit::write(result, file = dockerfile_name)
}