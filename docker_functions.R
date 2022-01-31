setup_streamline_scripts = function(
  secret = "ssh-deploy-key"
) {
  c(
    googleCloudRunner::cr_buildstep_gitsetup(secret),
    trailrun::cr_buildstep_git_clone(
      "git@github.com:StreamlineDataScience/streamline_startup_scripts.git",
      default_directory = "/workspace"
    )
  )
}

