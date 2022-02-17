# From https://github.com/r-lib/actions/blob/v2-branch/setup-r-dependencies/action.yaml
options(crayon.enabled = TRUE)
if (Sys.getenv("_R_CHECK_FORCE_SUGGESTS_", "") == "") {
  Sys.setenv("_R_CHECK_FORCE_SUGGESTS_" = "false")
}
rcmdcheck::rcmdcheck(
  args = c("--no-manual", "--as-cran"), 
  build_args = "--no-manual", 
  error_on = "warning", 
  check_dir = "check")
