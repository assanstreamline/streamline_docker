
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
ls -la
echo "PWD is ${PWD}"
R -f /package_scripts/install_deps.R

# do we need ssh capabilities in the package?
# I don't think generally, but may need to change this in the future
# using this so that .ssh isn't in the check folder anywhere
rm -rf .ssh/
package_name=`cat DESCRIPTION | grep Package: | awk '{print $2}'` && \
echo "package_name is ${package_name}" && \
R -f /package_scripts/check_package.R || exit_code=$?


echo "ls"
ls -la
echo "ls workspace"
ls -la /workspace || true
tar cvzf /workspace/${package_name}_check.tar.gz check/ || true

# Need to extract bucket name or pass this through
if [[ ${exit_code} -ne 0 ]] && [[ -n "${GCS_DEFAULT_BUCKET}" ]]; then
  suffix=`date +"%Y-%m-%d"`
  gsutil cp /workspace/${package_name}_check.tar.gz gs://${bucket_name}/${package_name}_check_${suffix}.tar.gz || true
fi
exit ${exit_code}

