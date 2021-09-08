make_volume = function(name, path) {
  list(list(name = name, path = path))
}


cr_buildstep_secret_json = function(
  secret, 
  default_directory = "/workspace", 
  # volumes = make_volume("default", default_directory),
  ...) {
  decrypted = fs::path(default_directory, paste0(secret, ".json"))
  x = cr_buildstep_secret(
    secret = secret, decrypted = decrypted, 
    # volumes = volumes, 
    ...)
  attr(x, "json_file") = decrypted
  x
}


# cr_buildstep_app_cred = function(
#   path = "/workspace/whoami.txt", ...) {
#   
#   steps = cr_buildstep_echo("$$GOOGLE_APPLICATION_CREDENTIALS")
#   script <- sprintf(
#     "gcloud auth application-default login"
#   )
#   
#   # ~/.config/gcloud/application_default_credentials.json
#   x = cr_buildstep(
#     args = c("-c", script),
#     name = "gcr.io/cloud-builders/gcloud",
#     entrypoint = "bash",
#     ...
#   )
#   attr(x, "path") = path
#   x
# }




cr_buildstep_touch = function(
  files, 
  default_directory = "/workspace", 
  # volumes = make_volume("default", default_directory), 
  ...) {
  files = fs::path(default_directory, files)
  cmds = paste("touch", files)
  sh_file = tempfile(fileext = ".sh")
  writeLines(cmds, sh_file)
  cr_buildstep_bash(
    bash_script = sh_file, 
    # volumes = volumes, 
    ...)
}


cr_buildstep_secret_binary <- function(
  secret,
  decrypted,
  version = "latest",
  binary_mode = TRUE,
  ...){
  # as per
  # https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets#a_note_on_resource_consistency
  decode_it = "--format='get(payload.data)' | tr '_-' '/+' | base64 -d"
  script <- sprintf(
    "gcloud secrets versions access %s --secret=%s %s > %s",
    version, secret, ifelse(binary_mode, decode_it, ""), decrypted
  )
  
  cr_buildstep(
    args = c("-c", script),
    name = "gcr.io/cloud-builders/gcloud",
    entrypoint = "bash",
    ...
  )
  
}

cr_empty_token = function(
  path = "/workspace/token.rds",
  # volumes = default_volume,
  ...) {
  rcode = sprintf('saveRDS(NULL, file = "%s")', path)
  tfile = tempfile(fileext = ".R")
  writeLines(rcode, tfile)
  cr_buildstep_r(rcode, 
                 # volumes = volumes, 
                 ...)
}

cr_buildstep_whoami = function(
  path = "/workspace/whoami.txt", ...) {
  
  script <- sprintf(
    "gcloud config list --format='value(core.account)' > %s",
    path
  )
  
  x = cr_buildstep(
    args = c("-c", script),
    name = "gcr.io/cloud-builders/gcloud",
    entrypoint = "bash",
    ...
  )
  attr(x, "path") = path
  x
}


cr_buildstep_sa_json = function(
  account = NULL, 
  path = "/workspace/service_account.json",
  ...) {
  gsteps = NULL
  orig_account = account
  if (is.null(account)) {
    gsteps = cr_buildstep_whoami(...)
    account = paste0("$(cat ", attr(gsteps, "path"), ")")
  }
  script <- sprintf(
    paste0(
      "echo \"Account is %s\" && ", 
      "gcloud iam service-accounts keys create \"%s\" --iam-account=%s"
    ), 
    account, path, account)
  steps = c(
    gsteps, 
    cr_buildstep(
      args = c("-c", script),
      name = "gcr.io/cloud-builders/gcloud",
      entrypoint = "bash",
      ...
    )
  )
  attr(steps, "json_file") = path
  attr(steps, "account") = orig_account
  steps
}

cr_buildstep_sa_key_delete = function(
  account = NULL, 
  path = "/workspace/service_account.json",
  private_key_id = NULL,
  ...) {
  gsteps = NULL
  if (is.null(account)) {
    gsteps = cr_buildstep_whoami(...)
    account = paste0("$(cat ", attr(gsteps, "path"), ")")
  }
  if (is.null(private_key_id)) {
    cmd = sprintf(
      paste0('writeLines(jsonlite::read_json("%s")$private_key_id, ', 
             '"/workspace/private_id.txt")'),
             path
    )
    gsteps = c(gsteps, 
               cr_buildstep_r(r = cmd, name = "verse")
    )
    private_key_id = "`cat /workspace/private_id.txt`"
  }
  stopifnot(!is.null(private_key_id))
  script <- sprintf(
    paste0(
      "echo \"Account is %s\" && ", 
      'echo "Y" | gcloud iam service-accounts keys delete "%s" --iam-account=%s'
    ), 
    account, private_key_id, account)
  c(
    gsteps, 
    cr_buildstep(
      args = c("-c", script),
      name = "gcr.io/cloud-builders/gcloud",
      entrypoint = "bash",
      ...
    )
  )
}

cr_buildstep_sa_key_delete_step = function(json_step, ...) {
  account = attr(json_step, "account")
  path = attr(json_step, "json_file")
  cr_buildstep_sa_key_delete(
    account = account, 
    path = path,
    private_key_id = NULL,
    ...)
}




cr_buildstep_ls = function(path, ...) {
  cmd = paste0("cd ", path, "; ls")
  cr_buildstep_bash(cmd, ...)
}

cr_buildstep_echo_lines = function(path, lines, ...) {
  cmd = paste0('echo "', lines, '" >> ', path)
  cr_buildstep_bash(cmd, ...)
}

cr_buildstep_cat = function(path, ...) {
  cmd = paste0("cat ", path)
  cr_buildstep_bash(cmd, ...)
}


cr_buildstep_echo = function(string, ...) {
  cmd = paste0("echo ", string)
  cr_buildstep_bash(cmd, ...)
}