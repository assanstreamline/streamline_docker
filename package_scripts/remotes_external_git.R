if (!requireNamespace("sessioninfo", quietly = TRUE)) {
  install.packages("sessioninfo")
}
info = sessioninfo::package_info("remotes")
if (!requireNamespace("remotes", quietly = TRUE) || 
    !any(grepl("muschellij2", info$source))) {
  remotes::install_github("muschellij2/remotes")
  unloadNamespace("remotes")
}
info = sessioninfo::package_info("remotes")
stopifnot(any(grepl("muschellij2", info$source)))

