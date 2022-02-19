
################################################
# SSH Key adding
################################################
eval $(ssh-agent) 
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

echo "ls /root"
ls -l /root || true
echo "ls /root/.ssh"
ls -l /root/.ssh || true

# trying to run the normal places ssh key exists
for ifile in /root/.ssh/id_rsa /ssh/.ssh/id_rsa /workspace/.ssh/id_rsa .ssh/id_rsa; 
do
  if [[ -f ${ifile} ]];
  then 
    echo "adding ${ifile} SSH KEY - running"
    chmod 600 ${ifile} && \
    ssh-add ${ifile}
  else 
    echo "No ${ifile} SSH key Found!"
  fi
done
# this is in case we're using in local directory
R -e "if (requireNamespace('usethis')) usethis::use_build_ignore('.ssh')"

# Just checking remotes version
R -e "if (requireNamespace('sessioninfo')) sessioninfo::package_info(pkgs = 'remotes')"

echo "ls"
ls -l
echo "PWD is ${PWD}"
R -f /package_scripts/install_deps.R
package_name=`cat DESCRIPTION | grep Package: | awk '{print $2}'` && \
R -f /package_scripts/check_package.R || exit_code=$?

echo "ls"
ls -l
echo "ls workspace"
ls -l /workspace || true
tar cvzf ${package_name}_check.tar.gz check/ || true
exit ${exit_code}

