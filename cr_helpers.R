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
  if (is.null(account)) {
    gsteps = cr_buildstep_whoami(...)
    account = paste0("$(cat ", attr(gsteps, "path"), ")")
  }
  script <- sprintf(
    paste0(
      "export ACCOUNT=%s && ", 
      "echo \"Account is $$ACCOUNT\" && ", 
      "gcloud iam service-accounts keys create \"%s\" --iam-account=$$ACCOUNT"
    ), 
    account, path)
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



cr_buildstep_ls = function(path, ...) {
  cmd = paste0("cd ", path, "; ls")
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