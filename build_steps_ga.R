# Sys.setenv(GAR_CLIENT_JSON = "~/streamline-demo/auths/client.json")
# Sys.setenv(GAR_AUTH_FILE = "~/streamline-demo/download/service_account.json")
# Sys.setenv(GCE_AUTH_FILE = Sys.getenv("GAR_AUTH_FILE"))


# cr_email_set
library(googleCloudRunner)
source("cr_helpers.R")
default_directory = "/workspace"

default_volume_with_git = default_volume_with_git()
default_volume = default_volume()

# Private keys/auth
# https://cloud.google.com/iam/docs/creating-managing-service-account-keys#getting_a_service_account_key
# You can only get the private key data for a service account key when the key is first created.

cr_project_set("streamline-demo-311819")
auth_files = c(Sys.getenv("GAR_AUTH_FILE", unset = NA),
               Sys.getenv("GCE_AUTH_FILE", unset = NA)
)
cr_region_set("us-east4")

# you have specified a JSON file
if (any(!is.na(auth_files)) & file.exists(auth_files)) {
  
} else {
  # if you are on GCE
  if (metagce::detect_gce() && 
      # needs to check if they are the same
      cr_project_get() == metagce::gce_project()
  ) {
    opts = options()
    options(httr_oauth_cache = FALSE)
    token = gargle::credentials_gce()
    options(opts)
    stopifnot(any(token$params$scope %in% 
          "https://www.googleapis.com/auth/cloud-platform"))
    googleAuthR::gar_auth(token = token)
  }
}

cr_email_set(jsonlite::read_json(Sys.getenv("GAR_AUTH_FILE"))$client_email)
# image = "gcr.io/streamline-resources/streamliner:latest"
r_lines <- c(
  "R.version",
  "list.files()",
  "getwd()",
  "file.exists('.Renviron')",
  "file.exists('client.json')",
  "file.exists('service_account.json')",
  "if (file.exists('.Renviron')) readLines('.Renviron')",
  'library(googleAuthR)',
  'library(googleAnalyticsR)',
  'library(gargle)',
  'sessioninfo::session_info("gargle")',
  # 'token = readRDS("token.rds")',
  # 'print(token)',
  'options(gargle_verbosity = "debug")',
  'options(gargle_oauth_cache = FALSE)',
  'token$cache_path = NULL',
  paste0("streamline.demo::google_analytics_pull_raw(", 
         # "email = 'muschellij2@gmail.com', ", 
         "json_file = 'service_account.json')")
  # "token = token)")
)

files = c("service_account.json", "client.json", 
          "github-api-key.json")


dockerfile = file.path(default_directory, 
                       # "streamline_docker", 
                       "dockerfiles/Dockerfile_github_GA")
location = file.path(default_directory)
# , "streamline_docker")
the_image_tagged = "googleAnalyticsAuthed"

api_key_step = cr_buildstep_secret_json("github-api-key")



whoami_step = cr_buildstep_whoami()
json_create_step = cr_buildstep_sa_json(
  account = "gcloudrunner@streamline-demo-311819.iam.gserviceaccount.com")

# check the script runs ok
steps = c(
  whoami_step,
  cr_buildstep_cat(attr(whoami_step, "path")),
  json_create_step
)
steps = c(
  steps, 
  cr_buildstep_ls(default_directory),
  cr_buildstep_touch(files, bash_source = "local"),
  # cr_empty_token(),
  api_key_step,
  cr_buildstep_ls(default_directory),
  # this gives the required token
  # cr_buildstep_secret_binary(
  #   "ga-token", 
  #   decrypted = file.path(default_directory, "token.rds")
  #   # ,
  #   # volumes = default_volume
  # ),
  cr_buildstep_secret_binary(
    "ga-client", 
    decrypted = file.path(default_directory, "client.json")
    # ,
    # volumes = default_volume
  )
)

steps = c(
  steps,
  cr_buildstep_ls(default_directory),
  cr_buildstep_gitsetup("github-ssh-muschellij2"),
  cr_buildstep(
    "git",
    c("clone",
      "git@github.com:StreamlineDataScience/streamline_docker", 
      file.path(default_directory, "streamline_docker")
    ),
    volumes = git_volume()
  ),
  # this is needed because otherwise running in the
  # subdirectory and need ../
  cr_buildstep_bash(
    paste("mv", file.path(default_directory, "streamline_docker/*"),
          "/workspace")
  ),
  # if 
  cr_buildstep(
    "git",
    args = 
      c("clone",
        "git@github.com:StreamlineDataScience/streamline-demo", 
        file.path(default_directory, "package")
      ),
    volumes = git_volume()
  ), # change the default (for the Docker)
  
  # show that you can do the remotes install with SSH 
  # as long as with install_git
  cr_buildstep_r(name = "verse",
                 c("install.packages('git2r')",
                   paste0("remotes::install_git('", 
                          "git@github.com:StreamlineDataScience/streamline-demo')")
                 ), 
                 volumes = git_volume()
  ), # change the default (for the Docker)
  
  cr_buildstep_ls(default_directory),
  cr_buildstep_echo_lines(file.path(default_directory, ".Renviron"),
                          "GAR_CLIENT_JSON=client.json"),
  cr_buildstep_echo_lines(file.path(default_directory, ".Renviron"),
                          "GAR_AUTH_FILE=service_account.json"),
  cr_buildstep_echo_lines(file.path(default_directory, ".Renviron"),
                          "GCE_AUTH_FILE=service_account.json"),
  cr_buildstep(
    "docker",
    c("build",
      # "--build-arg",
      # paste0(
      #   "GPAT=`cat ", 
      #   attr(api_key_step, "json_file"), 
      #   "`"
      # ),
      "-t", "ga_auth",
      "-f", dockerfile,
      # the_image_tagged,
      location)
    # ,
    # volumes = default_volume_with_git
  )
)
post_steps = c(
  cr_buildstep_sa_key_delete_step(json_create_step)
)

# other way of doing this
# build <- cr_build_yaml(
#   steps = c(steps,
#             cr_buildstep_r(r = r_lines,
#                            name = r_image,
#                            id = run_name,
#                            ...),
#             post_steps)
# )


outbuild = cr_deploy_r(
  r_lines, pre_steps = steps,
  r_image = "ga_auth", prefix = "",
  timeout = 3600L,
  # daily at 8 AM
  # schedule = "0 8 * * *",
  post_steps = post_steps)



