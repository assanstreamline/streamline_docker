#' make_volume = function(name, path) {
#'   list(list(name = name, path = path))
#' }
#' 
#' default_volume = function(default_directory = "/workspace") {
#'   make_volume(name = "default", path = default_directory)
#' }
#' 
#' default_volume_with_git = function(...) {
#'   default_volume = default_volume(...)
#'   c(git_volume(), default_volume)
#' }
#' 
#' cr_check_config = function(project = NULL,
#'                            region = NULL,
#'                            email = NULL) {
#'   if (is.null(project)) {
#'     project = cr_project_get()
#'   } else {
#'     cr_project_set(project)
#'   }
#'   if (is.null(region)) {
#'     region = cr_region_get()
#'   } else {
#'     cr_region_set(region)
#'   }
#'   if (is.null(email)) {
#'     # using cr_email_get as a failing stop
#'     email = try({cr_email_get()}, silent = TRUE)
#'     gar_auth_file = Sys.getenv("GAR_AUTH_FILE", unset = NA)
#'     gce_auth_file = Sys.getenv("GCE_AUTH_FILE", unset = NA)
#'     auth_files = c(gce_auth_file, gar_auth_file)
#'     auth_files = na.omit(auth_files)
#'     
#'     if (inherits(email, "try-error") && 
#'         length(auth_files) > 0 &&
#'         any(file.exists(auth_files))) {
#'       json_file = auth_files[1]
#'       email = jsonlite::read_json(json_file)$client_email
#'       if (is.null(email)) {
#'         email = cr_email_get()
#'       }
#'       cr_email_set(email)
#'     } else {
#'       # email = "default"
#'       # if (gargle:::detect_gce()) {
#'       #   token = gargle::credentials_gce()
#'       # }
#'       email = cr_email_get()
#'     }
#'   } else {
#'     cr_email_set(email)
#'   }
#'   L = list(
#'     project = project,
#'     region = region,
#'     email = email
#'   )
#'   
#' }
#' 
#' cr_buildstep_secret_json = function(
#'   secret, 
#'   default_directory = "/workspace", 
#'   # volumes = make_volume("default", default_directory),
#'   ...) {
#'   args = list(...)
#'   stopifnot(length(secret) == 1 && is.character(secret))
#'   args$secret = secret
#'   if (!"decrypted" %in% names(args)) {
#'     args$decrypted = file.path(default_directory, 
#'                               paste0(secret, ".json"), 
#'                               fsep = "/")
#'   }
#'   x = do.call(cr_buildstep_secret, args = args)
#'   attr(x, "json_file") = args$decrypted
#'   x
#' }
#' 
#' 
#' # cr_buildstep_app_cred = function(
#' #   path = "/workspace/whoami.txt", ...) {
#' #   
#' #   steps = cr_buildstep_echo("$$GOOGLE_APPLICATION_CREDENTIALS")
#' #   script <- sprintf(
#' #     "gcloud auth application-default login"
#' #   )
#' #   
#' #   # ~/.config/gcloud/application_default_credentials.json
#' #   x = cr_buildstep(
#' #     args = c("-c", script),
#' #     name = "gcr.io/cloud-builders/gcloud",
#' #     entrypoint = "bash",
#' #     ...
#' #   )
#' #   attr(x, "path") = path
#' #   x
#' # }
#' 
#' cr_buildstep_touch_r_file = function(
#'   path = "/workspace/token.rds",
#'   ...) {
#'   
#'   ext = tools::file_ext(path)
#'   ext = tolower(ext)
#'   rcode = switch(
#'     ext,
#'     rds = sprintf('saveRDS(NULL, file = "%s")', path),
#'     rda = sprintf('save(file = "%s")', path)
#'   )
#'   if (is.null(rcode)) {
#'     stop("Using touch for R file, but not rds/rda!")
#'   }
#'   cr_buildstep_r(rcode, 
#'                  ...)
#' }
#' 
#' #' @examples 
#' #' cr_buildstep_touch(c("blah.json", "blah.rds", "blah.rda", "blah.txt"))
#' cr_buildstep_touch = function(
#'   files, 
#'   default_directory = "/workspace", 
#'   # volumes = make_volume("default", default_directory), 
#'   ...) {
#'   files = fs::path(default_directory, files)
#'   exts = tools::file_ext(files)
#'   
#'   is_r_file = tolower(exts) %in% c("rds", "rda")
#'   r_files = files[is_r_file]
#'   files = files[!is_r_file]
#'   
#'   steps = NULL
#'   if (!all(is_r_file)) {
#'     cmds = paste("touch", files)
#'     sh_file = tempfile(fileext = ".sh")
#'     writeLines(cmds, sh_file)
#'     steps = cr_buildstep_bash(
#'       bash_script = sh_file, 
#'       ...)
#'   }
#'   if (any(is_r_file)) {
#'     steps = c(
#'       steps,
#'       unname(sapply(r_files, cr_buildstep_touch_r_file, 
#'                     ... = ...)
#'       )
#'     )
#'   }
#'   steps
#' }
#' 
#' cr_buildstep_mkdir = function(
#'   path, 
#'   args = NULL,
#'   ...) {
#'   cmd = paste("mkdir -p", paste(path, collapse = " "))
#'   cr_buildstep_bash(cmd, ...)
#' }
#' 
#' 
#' cr_buildstep_secret_binary <- function(
#'   secret,
#'   decrypted,
#'   version = "latest",
#'   binary_mode = TRUE,
#'   ...){
#'   # as per
#'   # https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets#a_note_on_resource_consistency
#'   decode_it = "--format='get(payload.data)' | tr '_-' '/+' | base64 -d"
#'   script <- sprintf(
#'     "gcloud secrets versions access %s --secret=%s %s > %s",
#'     version, secret, ifelse(binary_mode, decode_it, ""), decrypted
#'   )
#'   
#'   cr_buildstep(
#'     args = c("-c", script),
#'     name = "gcr.io/cloud-builders/gcloud",
#'     entrypoint = "bash",
#'     ...
#'   )
#'   
#' }
#' 
#' cr_empty_token = function(
#'   path = "/workspace/token.rds",
#'   # volumes = default_volume,
#'   ...) {
#'   rcode = sprintf('saveRDS(NULL, file = "%s")', path)
#'   tfile = tempfile(fileext = ".R")
#'   writeLines(rcode, tfile)
#'   cr_buildstep_r(rcode, 
#'                  # volumes = volumes, 
#'                  ...)
#' }
#' 
#' cr_buildstep_whoami = function(
#'   path = "/workspace/whoami.txt", ...) {
#'   
#'   script <- sprintf(
#'     "gcloud config list --format='value(core.account)' > %s",
#'     path
#'   )
#'   
#'   x = cr_buildstep(
#'     args = c("-c", script),
#'     name = "gcr.io/cloud-builders/gcloud",
#'     entrypoint = "bash",
#'     ...
#'   )
#'   attr(x, "path") = path
#'   x
#' }
#' 
#' 
#' cr_buildstep_sa_json = function(
#'   account = NULL, 
#'   path = "/workspace/service_account.json",
#'   ...) {
#'   gsteps = NULL
#'   orig_account = account
#'   if (is.null(account)) {
#'     gsteps = cr_buildstep_whoami(...)
#'     account = paste0("$(cat ", attr(gsteps, "path"), ")")
#'   }
#'   script <- sprintf(
#'     paste0(
#'       "echo \"Account is %s\" && ", 
#'       "gcloud iam service-accounts keys create \"%s\" --iam-account=%s"
#'     ), 
#'     account, path, account)
#'   steps = c(
#'     gsteps, 
#'     cr_buildstep(
#'       args = c("-c", script),
#'       name = "gcr.io/cloud-builders/gcloud",
#'       entrypoint = "bash",
#'       ...
#'     )
#'   )
#'   attr(steps, "json_file") = path
#'   attr(steps, "account") = orig_account
#'   steps
#' }
#' 
#' cr_buildstep_sa_key_delete = function(
#'   account = NULL, 
#'   path = "/workspace/service_account.json",
#'   private_key_id = NULL,
#'   ...) {
#'   gsteps = NULL
#'   if (is.null(account)) {
#'     gsteps = cr_buildstep_whoami(...)
#'     account = paste0("$(cat ", attr(gsteps, "path"), ")")
#'   }
#'   if (is.null(private_key_id)) {
#'     cmd = sprintf(
#'       paste0('writeLines(jsonlite::read_json("%s")$private_key_id, ', 
#'              '"/workspace/private_id.txt")'),
#'       path
#'     )
#'     gsteps = c(gsteps, 
#'                cr_buildstep_r(r = cmd, name = "verse")
#'     )
#'     private_key_id = "`cat /workspace/private_id.txt`"
#'   }
#'   stopifnot(!is.null(private_key_id))
#'   script <- sprintf(
#'     paste0(
#'       "echo \"Account is %s\" && ", 
#'       'echo "Y" | gcloud iam service-accounts keys delete "%s" --iam-account=%s'
#'     ), 
#'     account, private_key_id, account)
#'   c(
#'     gsteps, 
#'     cr_buildstep(
#'       args = c("-c", script),
#'       name = "gcr.io/cloud-builders/gcloud",
#'       entrypoint = "bash",
#'       ...
#'     )
#'   )
#' }
#' 
#' cr_buildstep_sa_key_delete_step = function(json_step, ...) {
#'   account = attr(json_step, "account")
#'   path = attr(json_step, "json_file")
#'   cr_buildstep_sa_key_delete(
#'     account = account, 
#'     path = path,
#'     private_key_id = NULL,
#'     ...)
#' }
#' 
#' cr_gce_setup = function(region = NULL,
#'                         service_account = "default",
#'                         cache = FALSE) {
#'   if (!metagce::detect_gce()) {
#'     stop("cr_gce_setup only works in GCE!")
#'   }
#'   if (is.null(region)) {
#'     region = metagce::gce_instance_region()
#'   }
#'   project = metagce::gce_project()
#'   cr_project_set(project)
#'   
#'   cr_region_set(region)
#'   # I don't want caching, even if in interactive session
#'   # as this can be called by any GCE machine
#'   opts = options()
#'   options(httr_oauth_cache = cache)
#'   # googleAuthR::gar_gce_auth takes 2 steps away
#'   token = googleAuthR::gar_gce_auth(
#'     service_account = service_account
#'   )
#'   # token = gargle::credentials_gce()
#'   # googleAuthR::gar_auth(token = token)
#'   # reset the auth
#'   options(opts)
#'   stopifnot(any(token$params$scope %in% 
#'                   "https://www.googleapis.com/auth/cloud-platform"))
#'   email = token$params$service_account
#'   cr_email_set(email)
#'   L = list(
#'     project = project,
#'     region = region,
#'     email = email,
#'     token = token
#'   )
#' }
#' 
#' 
#' cr_buildstep_ls = function(path, args = NULL, ...) {
#'   cmd = paste(c(paste0("cd ", path, ";"), "ls", args),
#'               collapse = " ")
#'   cr_buildstep_bash(cmd, ...)
#' }
#' 
#' cr_buildstep_echo_lines = function(path, lines, ...) {
#'   cmd = paste0('echo "', lines, '" >> ', path)
#'   cr_buildstep_bash(cmd, ...)
#' }
#' 
#' cr_buildstep_cat = function(path, ...) {
#'   cmd = paste0("cat ", path)
#'   cr_buildstep_bash(cmd, ...)
#' }
#' 
#' 
#' cr_buildstep_echo = function(string, ...) {
#'   cmd = paste0("echo ", string)
#'   cr_buildstep_bash(cmd, ...)
#' }
#' 
#' cr_buildstep_docker_auth = function(
#'   registry,
#'   ...) {
#'   cr_buildstep_gcloud(
#'     "gcloud",
#'     c("gcloud", "auth", "configure-docker", 
#'       paste(registry, collapse = ",")
#'     ),
#'     ...
#'   )
#' }
#' 
#' cr_buildstep_docker_auth_location = function(
#'   location = "us",
#'   ...) {
#'   registry = sapply(location, function(x) {
#'     paste0(x, c("-docker.pkg.dev", ".gcr.io"))
#'   })
#'   registry = unname(c(unlist(registry)))
#'   cr_buildstep_docker_auth(
#'     registry = registry,
#'     ...
#'   )
#' 
#' }

cr_buildstep_git_packages = function(
  repos, 
  path = "/workspace/deploy/packages",
  clone_args = NULL,
  ...) {
  i <- 1
  git_steps = sapply(repos, function(repo) {
    res = remotes:::git_remote(repo)
    repo = res$url
    ref = res$ref
    iord = sprintf("%04.0f", i)
    out_path = file.path(path, paste0(iord, "-", basename(repo)))
    i <<- i + 1
    step = cr_buildstep_git(
      git_args = c(
        "clone", 
        clone_args,
        repo,        
        out_path
      ),
      ...
    )
    if (!is.null(ref) && !ref %in% c("master", "main", "HEAD")) {
      step = c(
        step, 
        cr_buildstep_git(
          git_args = c("-C", out_path, "checkout", ref),
          ...
        )
      )
    }
    step
  })
  
  git_steps = unname(git_steps)
  c(
    cr_buildstep_mkdir(path),
    git_steps
  )
}