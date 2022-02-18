
eval $(ssh-agent) 
echo "ls /root"
ls -l /root || true
echo "ls /root/.ssh"
ls -l /root/.ssh || true
if [[ -f /root/.ssh/id_rsa ]];
then 
echo "adding SSH KEY - running"
chmod 600 /root/.ssh/id_rsa && \
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
ssh-add /root/.ssh/id_rsa
else 
echo "No SSH key Found!"
fi

if [[ -f /ssh/.ssh/id_rsa ]];
then 
echo "adding ssh SSH KEY - running"
chmod 600 /ssh/.ssh/id_rsa && \
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
ssh-add /ssh/.ssh/id_rsa
else 
echo "No ssh SSH key Found!"
fi

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

