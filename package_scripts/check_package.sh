package_name=`cat DESCRIPTION | grep Package: | awk '{print $2}'` && \
R /package_scripts/check_package.R || exit_code=$?

tar xzf tar cvzf ${package_name}_check.tar.gz check/ 
exit ${exit_code}