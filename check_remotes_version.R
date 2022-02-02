check_remotes_version = function() {
  if (!requireNamespace("remotes", quietly = TRUE) |
      packageVersion("remotes") <= package_version("2.4.2")) {
    remotes::install_github("muschellij2/remotes")
    unloadNamespace("remotes")
  }
  stopifnot(packageVersion("remotes") >= package_version("2.4.2"))
}
check_remotes_version()