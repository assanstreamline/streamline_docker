print(sessioninfo::package_info("remotes"))
pack_dir = list.dirs('/packages', recursive = FALSE)
for (idir in pack_dir) {
  remotes::install_local(path = idir, git = "external")
}
