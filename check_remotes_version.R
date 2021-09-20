check_remotes_version = function() {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
  }
  if (packageVersion("remotes") <= package_version("2.4.0.9000")) {
    remotes::install_github("r-lib/remotes")
    # remotes::install_github("r-lib/remotes@920e4a3")
    unloadNamespace("remotes")
  }
  stopifnot(packageVersion("remotes") >= package_version("2.4.0.9000"))
}
check_remotes_version()