# Simple helper function to get the email for the service account
# this is needed for creating keys
get_account_email() {
    iam_account_email=`gcloud iam service-accounts list --filter="name ~ ${1}" --format="value(email)"`
}

# getting the project out - verbose for printing
get_project() {
    echo "Getting project information from GOOGLE_CLOUD_PROJECT";
    project=${GOOGLE_CLOUD_PROJECT} ;
    if [ -z "${project}" ];
    then 
        echo "No GOOGLE_CLOUD_PROJECT set, getting project information from gcloud config";
        project=`gcloud config list --format 'value(core.project)'`
    fi
}

# use this programmatically
get_project_quiet() {
    project=${GOOGLE_CLOUD_PROJECT} ;
    if [ -z "${project}" ];
    then 
        project=`gcloud config list --format 'value(core.project)'`
    fi    
    echo $project    
}

function_check() {
    if [ -z "${1}" ];
    then
        echo "No function given"
        [ "$0" = "$BASH_SOURCE" ] && exit 1 || return 1
    fi
    has_function=`which ${1}`
    if [ -z "${has_function}" ];
    then
        echo "${1} is not installed on this machine, failing"
        # else for failure, return non-0
        # no kill shell from 
        # https://unix.stackexchange.com/questions/268560/return-an-exit-code-without-killing-callers-terminal
        [ "$0" = "$BASH_SOURCE" ] && exit 1 || return 1
    fi
}

# checking if gcloud is installed
gcloud_check() {
    function_check gcloud
}

# checking if gcloud is installed
git_check() {
    function_check git
}
