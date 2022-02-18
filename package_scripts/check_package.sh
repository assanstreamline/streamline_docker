
if [[ -f /root/.ssh/id_rsa ]];
then
eval $(ssh-agent) && \
chmod 600 /root/.ssh/id_rsa && \
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
ssh-add /root/.ssh/id_rsa
fi

R -e "if (requireNamespace('sessioninfo')) sessioninfo::package_info(pkgs = 'remotes')"
echo "ls"
ls -l
echo "ls workspace"
ls -l /workspace || true
echo "PWD is ${PWD}"
R -f /package_scripts/install_deps.R
package_name=`cat DESCRIPTION | grep Package: | awk '{print $2}'` && \
R -f /package_scripts/check_package.R || exit_code=$?

echo "ls"
ls -l
echo "ls workspace"
ls -l /workspace || true
tar xzf tar cvzf ${package_name}_check.tar.gz check/ 
exit ${exit_code}