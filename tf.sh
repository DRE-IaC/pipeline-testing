#!/usr/bin/env bash

# the return value of the last (rightmost) command to exit with a non-zero status
set -o pipefail;
# Treat unset variables and parameters other than the special parameters ‘@’ or ‘*’ as an error when performing parameter expansion.
set -u;

##
# Options parsing.
##
OPTIND=1;

# text formatting options
bold=$(tput bold);
normal=$(tput sgr0);
RED='\033[0;31m';
CYAN='\033[0;36m';
NC='\033[0m'; # No Color

# script usage
function usage() {
    cat << EOF
Usage: ${0##*/} [-e ENVIRONMENT] [-a ACTION] [-p PROFILE] [-v REGION] [-o OPTION-1 -o OPTION-2 ... -o OPTION-N] [-s SKIP_INTERACTIVE] [-v VERBOSE]
Automates the process of infrastructure code deployments.

     -h | --help              display this help and exit

     -e | --environment       ENVIRONMENT the name of the environment. Allowed values are:
                              - sandbox (uses sandbox environment and 'sandbox' AWS profile by default. Please change the profile (-p PROFILE) according to your ~/.aws/config if necessary.)
                              - primary (uses dre environment and 'dre_admin' AWS profile by default. Please change the profile (-p PROFILE) according to your ~/.aws/config if necessary.)

     -a | --action            ACTION the terraform action to perform. Allowed values are:
                              - init             (initialize working directory containing terraform configuration files)
                              - plan             (creates an execution plan, which lets you preview the changes)
                              - import           (associate existing infrastructure with a Terraform resource)
                              - state            (state management)
                              - apply            (apply infrastructure code to the chosen environment)
                              - destroy          (destroys infrastructure for the chosen environment)
                              - clean            (cleans the generated local terraform files)
                              - bigbang_diff     (Helm Revision for Desired and current)
                              - bigbang_upgrade  (Upgrade all Helm charts)
                              - install-ack-s3   (installs ACK S3 controller in namespace 'ack-system'.
                                                  Important: Before running install-ack-s3 make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                  If cluster is not accessible install-ack-s3 updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - uninstall-ack-s3 (uninstalls ACK S3 controller.
                                                  Important: Before running uninstall-ack-s3 make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                  If cluster is not accessible uninstall-ack-s3 updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - install-ack-iam   (installs ACK IAM controller in namespace 'ack-system'.
                                                  Important: Before running install-ack-iam make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                  If cluster is not accessible install-ack-iam updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - uninstall-ack-iam (uninstalls ACK IAM controller.
                                                  Important: Before running uninstall-ack-iam make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                  If cluster is not accessible uninstall-ack-iam updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - install-external-dns   (installs External Dns in namespace 'external-dns'.
                                                       Important: Before running install-external-dns make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                       If cluster is not accessible install-external-dns updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - uninstall-external-dns (uninstalls External Dns.
                                                       Important: Before running uninstall-external-dns make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                       If cluster is not accessible uninstall-external-dns updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - install-calico        (installs Calico in namespace 'calico-apiserver & calico-system'.
                                                       Important: Before running install-calico make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                       If cluster is not accessible install-calico updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - install-nginx-ingress  (installs Nginx Ingress in namespace 'ingress-nginx'.
                                                       Important: Before running install-nginx-ingress make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                       If cluster is not accessible install-nginx-ingress updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - namespace-creation     (For Creating Namespaces'.
                                                       Important: Before running namespace-creation make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                       If cluster is not accessible namespace-creation updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - install-ebs-storageclass  (installs EBS Storageclass to use GP3 PVs in namespace 'external-dns'.
                                                       Important: Before running install-ebs-storageclass make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                       If cluster is not accessible install-ebs-storageclass updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

                              - uninstall-ebs-storageclass (uninstalls EBS Storageclass.
                                                       Important: Before running uninstall-ebs-storageclass make sure your ~/.kube/config points to the selected environment (e.g kubectl-cf -> select <profile>).
                                                       If cluster is not accessible uninstall-ebs-storageclass updates ~/.kube/config by running 'aws eks update-kubeconfig --name dre-primary --profile <profile> --region <region>')

     -p | --profile           PROFILE the AWS profile to use, defaults to 'sandbox' for sandbox environment and 'dre_admin' for primary environment.
                              Please change the profile according to your ~/.aws/config if necessary.

     -r | --region            REGION the AWS region to use, defaults to 'us-east-1'. Please change the region according to your configuration if necessary.

     -o | --option            OPTION Additional options required for actions such as import or state (e.g. -o <option-1> -o <option-2> ... -o <option-N>).

     -s | --skip-interactive  SKIP_INTERACTIVE Skips interactive approval of changes before applying, default value is 'off'. Allowed values are:
                              - on
                              - off

     -v | --verbose           VERBOSE print detailed output, default value is false. Allowed values are:
                              - true
                              - false

     -c | --code-pipeline     CODE_PIPELINE determines if the execution takes place for AWS Code pipeline, default value is 'off'. Allowed values are:
                              - on
                              - off
EOF
}

function confirm() {
  read -r -p "${bold}Are you sure you want to proceed? [y/N]${normal} " response
  case "$response" in
      [yY][eE][sS]|[yY])
          echo "Proceeding...";
          ;;
      *)
          echo "Exiting...";
          exit 1;
          ;;
  esac
}

# short and long parameter names
SHORT=?he:a:p:r:o:s:v:c:
LONG=help,environment:,action:,profile:,region:,option:,skip-interactive:,verbose:,code-pipeline:

# get params
OPTS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@");

# failed to pass command line parameters
if [ $? != 0 ]; then
    echo "Failed to parse options... see --help for detailed usage." >&2;
    exit 1;
fi

# start command line parameters parsing
eval set -- "$OPTS";
environment=;
action=;
arn=;
role=;
profile=;
opts=;
skip_interactive=off;
region=us-east-2;
verbose=false;
cluster_name=dre-primary2;
code_pipeline=off;
while true ; do
    case "$1" in
        -h | --help)
            usage;
            exit 0;
            ;;
        -e | --environment)
            environment=$2;
            shift 2;
            ;;
        -a | --action)
            action=$2;
            shift 2;
            ;;
        -p | --profile)
            profile=$2;
            shift 2;
            ;;
        -r | --region)
            region=$2;
            shift 2;
            ;;
        -o | --option)
            if [[ -z $opts ]]; then
              opts=$2;
            else
              opts+=" "$2;
            fi
            shift 2;
            ;;
        -s | --skip-interactive)
            skip_interactive=$2;
            shift 2;
            ;;
        -v | --verbose)
            verbose=$2;
            shift 2;
            ;;
        -c | --code-pipeline)
            code_pipeline=$2;
            shift 2;
            ;;
        -- )
            shift;
            break;
            ;;
          *)
            exit 1;
            ;;
    esac
done

# no environment selected
if [ -z $environment ]; then
    echo -e ${bold}"ENVIRONMENT is a required parameter."${normal}"\n";
    usage;
    exit 1;
fi

# invalid environment selected
if [[ $environment != "primary" && $environment != "sandbox" ]]; then
    echo -e ${bold}"ENVIRONMENT has an invalid value."${normal}"\n";
    usage;
    exit 1;
fi

# setting profile based on your environment
if [ -z $profile ]; then
  if [[ $environment == "primary" ]]; then
      profile="controlplane";
  elif [[ $environment == "sandbox" ]]; then
      profile="sandbox";
  fi
fi

# checking if var file exist
if [ ! -f env/$environment/vars ]; then
    echo -e ${bold} "env/$environment/vars does not exist. You'll need to create a vars file for the requested environment before continuing."${normal};
    exit 1;
fi

# no profile selelcted
if [ -z $profile ]; then
    echo -e ${bold}"PROFILE must not be empty."${normal}"\n";
    usage;
    exit 1;
fi

# profile not found in ~/.aws/config
if [[ $profile != "default" ]]; then
  cat ~/.aws/config | grep -q "\[profile $profile\]";
else
  cat ~/.aws/config | grep -q "\[$profile\]";
fi
if [ $? != 0 ]; then
  echo -e ${RED}${bold}"Selected profile '$profile' not found under ~/.aws/config ."${normal}${NC}"\n";
  confirm;
fi

# no region selected
if [ -z $region ]; then
    echo -e ${bold}"REGION must not be empty."${normal}"\n";
    usage;
    exit 1;
fi

# no action selected
if [ -z $action ]; then
    echo -e ${bold}"ACTION is a required parameter."${normal}"\n";
    usage;
    exit 1;
fi

# invalid action selected
if [[ $action != "init" && $action != "plan" && $action != "import" && $action != "state" && $action != "apply" && $action != "clean" && $action != "destroy" && $action != "install-ack-s3"  && $action != "uninstall-ack-s3" && $action != "install-ack-iam"  && $action != "uninstall-ack-iam" && $action != "install-external-dns"  && $action != "uninstall-external-dns" && $action != "install-ebs-storageclass" && $action != "uninstall-ebs-storageclass" && $action != "install-calico" && $action != "install-nginx-ingress" && $action != "namespace-creation" && $action != "bigbang_diff" && $action != "bigbang_upgrade" ]]; then
  echo -e ${bold}"ACTION has an invalid value."${normal}"\n";
  usage;
  exit 1;
fi

# invalid import options selected
import_opts_pattern='^[^ ]+\s[^ ]+$';
if [[ $action == "import" && !($opts =~ $import_opts_pattern) ]]; then
  echo -e ${bold}"import does not match with the given options \""$opts"\"."${normal};
  echo -e ${bold}"(usage example: ./tf.sh -e sandbox -a import -o aws_iam_user_policy_attachment.ecrapiuser_ec2_describe_all -o ecrapiuser/arn:aws:iam::510467250861:policy/ecr-describe-al)."${normal}"\n";
  usage;
  exit 1;
fi

# invalid state options selected
if [[ $action == "state" && -z $opts ]]; then
  echo -e ${bold}"state does not match with the given options \""$opts"\"."${normal};
  echo -e ${bold}"(usage example: ./tf.sh -e sandbox -a state -o list)."${normal}"\n";
  usage;
  exit 1;
fi

# no skip interactive value selected
if [ -z $skip_interactive ]; then
    echo -e ${bold}"SKIP_INTERACTIVE must not be empty."${normal}"\n";
    usage;
    exit 1;
fi

# invalid skip interactive value selected
if [[ $skip_interactive != "on" && $skip_interactive != "off" ]]; then
    echo -e ${bold}"SKIP_INTERACTIVE has an invalid value."${normal}"\n";
    usage;
    exit 1;
fi

# no verbose value selected
if [ -z $verbose ]; then
    echo -e ${bold}"VERBOSE must not be empty."${normal}"\n";
    usage;
    exit 1;
fi

# invalid verbose value selected
if [[ $verbose != true && $verbose != false ]]; then
  echo -e ${bold}"VERBOSE has an invalid value."${normal}"\n";
  usage;
  exit 1;
fi

# no code pipeline value selected
if [ -z $code_pipeline ]; then
    echo -e ${bold}"CODE_PIPELINE must not be empty."${normal}"\n";
    usage;
    exit 1;
fi

# invalid code pipeline value selected
if [[ $code_pipeline != "on" && $code_pipeline != "off" ]]; then
  echo -e ${bold}"CODE_PIPELINE has an invalid value."${normal}"\n";
  usage;
  exit 1;
fi

# set ansible configuration file
ansible_config=ansible.cfg;
terraform_config=terraform.cfg;

# ansible config does not exist
if [ ! -f $ansible_config ]; then
  echo -e ${bold}"$ansible_config does not exist. You'll need to create an ansible config file."${normal}"\n";
  exit 1;
fi
# set ansible configuration file
export ANSIBLE_CONFIG=$(pwd)/$ansible_config;

# terraform config does not exist
if [ ! -f $terraform_config ]; then
    echo -e ${bold}"$terraform_config does not exist. You'll need to create a config file so we know where to set up the remote config."${normal}"\n";
    exit 1;
fi
# disable colors for terraform commands
export TF_CLI_ARGS="-no-color";

# prevent destroy from primary environment
if [[ $action == "destroy" && $environment == "primary" ]]; then
  echo -e "${RED}${bold}ATTENTION${normal}${NC} Destroying the configuration in the primary dre environment should not be allowed."
  exit 1;
fi

# ask for confirmation when apply or destroy is selected
if [[ $skip_interactive == "off" && ( $action == "apply" || $action == "destroy" || ($action == "state" && ($opts != "list" && $opts != "pull" && $opts != *"show"*)) || $action == "import" || $action == "install-ack-s3" || $action == "uninstall-ack-s3" || $action == "install-external-dns"  || $action == "uninstall-external-dns" || $action == "bigbang_diff" || $action == "bigbang_upgrade" ) ]]; then
  echo -e "${RED}${bold}PLEASE READ CAREFULLY!${normal}${NC}\nThe infrastructure code changes will be applied based on the following parameters:"
  echo -e "Environment: ${CYAN}${bold}$environment${normal}${NC}";
  echo -e "AWS profile (~/.aws/config): ${CYAN}${bold}$profile${normal}${NC}";
  echo -e "AWS region: ${CYAN}${bold}$region${normal}${NC}";
  echo -e "Action: ${CYAN}${bold}$action${normal}${NC}";
  echo -e "CodePipeline: ${CYAN}${bold}$code_pipeline${normal}${NC}";
  [[ -z "$opts" ]] && echo -e "Additional options: ${CYAN}${bold}None${normal}${NC}" || echo -e "Additional options: ${CYAN}${bold}$opts${normal}${NC}";
  echo -e "Verbose output: ${CYAN}${bold}$verbose${normal}${NC}";
  if [[ $action == "install-ack-s3" || $action == "uninstall-ack-s3" || $action == "install-external-dns"  || $action == "uninstall-external-dns" || $action == "bigbang_diff" || $action == "bigbang_upgrade" ]]; then
    echo -e "\n${bold}Important:${normal}\nBefore running $action make sure your ~/.kube/config currently used points to profile for $environment (e.g if not done already, kubectl-cf -> select profile). If cluster is not accessible $action updates ${bold}~/.kube/config${normal} in order to access the cluster with the following command:";
    echo -e "${CYAN}${bold}aws eks update-kubeconfig --name dre-primary2 --profile $profile --region $region ${normal}${NC}\n";
  fi
  confirm;
else
  echo -e "Environment: ${CYAN}${bold}$environment${normal}${NC}";
  echo -e "AWS profile (~/.aws/config): ${CYAN}${bold}$profile${normal}${NC}";
  echo -e "AWS region: ${CYAN}${bold}$region${normal}${NC}";
  echo -e "Action: ${CYAN}${bold}$action${normal}${NC}";
  echo -e "CodePipeline: ${CYAN}${bold}$code_pipeline${normal}${NC}";
  [[ -z "$opts" ]] && echo -e "Additional options: ${CYAN}${bold}None${normal}${NC}" || echo -e "Additional options: ${CYAN}${bold}$opts${normal}${NC}";
  echo -e "Verbose output: ${CYAN}${bold}$verbose${normal}${NC}";
  if [[ $action == "install-ack-s3" || $action == "uninstall-ack-s3" || $action == "install-external-dns"  || $action == "uninstall-external-dns" || $action == "bigbang_diff" || $action == "bigbang_upgrade" ]]; then
    echo -e "\n${bold}Important:${normal}\nBefore running $action make sure your ~/.kube/config currently used points to profile for $environment (e.g if not done already, kubectl-cf -> select profile). If cluster is not accessible $action updates ${bold}~/.kube/config${normal} in order to access the cluster with the following command:";
    echo -e "${CYAN}${bold}aws eks update-kubeconfig --name dre-primary2 --profile $profile --region $region ${normal}${NC}\n";
  fi
fi

if [[ $action != "clean" && $code_pipeline == "off" ]]; then
  # check if user is logged in to aws
  aws sts get-caller-identity --profile $profile --region $region &> /dev/null;
  if [ $? != 0 ]; then
    aws sso login;
  fi

  # select aws arn
  if [ -z $arn ]; then
      arn=$(aws sts get-caller-identity --profile $profile --region $region --query "Arn");
  fi

  # select aws role
  if [ -z $role ]; then
      arrARN=(${arn//// });
      role=$(aws iam get-role --role-name ${arrARN[1]} --profile $profile --region $region --query "Role.Arn" | sed s/\"//g);
  fi

  # set AWS session access keys and tokens
  echo "Assuming role: $role";
  export AWS_CREDENTIALS=$(aws sts assume-role --role-arn $role --role-session-name=assumed_role --profile $profile --region $region | jq -r '.Credentials' | cat);
  export AWS_ACCESS_KEY_ID=$(echo $AWS_CREDENTIALS | jq -r ".AccessKeyId");
  export AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDENTIALS | jq -r ".SecretAccessKey");
  export AWS_SESSION_TOKEN=$(echo $AWS_CREDENTIALS | jq -r ".SessionToken");
fi

# set verbose value for ansible
ansible_verbose_arg="";
if [ $verbose == true ]; then
    ansible_verbose_arg="-v";
fi

# run ansible playbook based on the selected action
case $action in

  "init")
    ansible-playbook $ansible_verbose_arg ./playbooks/init.yaml --extra-vars "terraform_config=$terraform_config env=$environment";
    ;;

  "plan")
    ansible-playbook $ansible_verbose_arg ./playbooks/plan.yaml --extra-vars "terraform_config=$terraform_config env=$environment";
    ;;

  "apply")
    if [[ $skip_interactive == "off" ]]; then
      ansible-playbook $ansible_verbose_arg ./playbooks/apply.yaml --extra-vars "terraform_config=$terraform_config env=$environment";
    elif [[ $skip_interactive == "on" ]]; then
      ansible-playbook $ansible_verbose_arg ./playbooks/apply_confirmed.yaml --extra-vars "terraform_config=$terraform_config env=$environment";
    fi
    ;;

  "destroy")
    if [[ $skip_interactive == "off" ]]; then
      ansible-playbook $ansible_verbose_arg ./playbooks/destroy.yaml --extra-vars "terraform_config=$terraform_config env=$environment";
    elif [[ $skip_interactive == "on" ]]; then
      ansible-playbook $ansible_verbose_arg ./playbooks/destroy_confirmed.yaml --extra-vars "terraform_config=$terraform_config env=$environment";
    fi
    ;;

  "import")
    ansible-playbook $ansible_verbose_arg ./playbooks/import.yaml --extra-vars "terraform_config=$terraform_config env=$environment opts='$opts'";
    ;;

  "state")
    ansible-playbook $ansible_verbose_arg ./playbooks/state.yaml --extra-vars "terraform_config=$terraform_config env=$environment opts='${opts}'";
    ;;

  "clean")
    ansible-playbook $ansible_verbose_arg ./playbooks/clean.yaml --extra-vars "env=$environment";
    ;;

  "install-ack-s3")
    ansible-playbook $ansible_verbose_arg ./playbooks/install_ack_s3.yaml --extra-vars "env=$environment region=$region";
    ;;

  "uninstall-ack-s3")
    ansible-playbook $ansible_verbose_arg ./playbooks/uninstall_ack_s3.yaml --extra-vars "env=$environment region=$region";
    ;;

  "install-ack-iam")
    ansible-playbook $ansible_verbose_arg ./playbooks/install_ack_iam.yaml --extra-vars "env=$environment region=$region";
    ;;

  "uninstall-ack-iam")
    ansible-playbook $ansible_verbose_arg ./playbooks/uninstall_ack_iam.yaml --extra-vars "env=$environment region=$region";
    ;;

  "install-external-dns")
    ansible-playbook $ansible_verbose_arg ./playbooks/install_external_dns.yaml --extra-vars "env=$environment region=$region";
    ;;

  "uninstall-external-dns")
    ansible-playbook $ansible_verbose_arg ./playbooks/uninstall_external_dns.yaml --extra-vars "env=$environment region=$region";
    ;;

  "install-nginx-ingress")
    ansible-playbook $ansible_verbose_arg ./playbooks/install_nginx_ingress.yaml --extra-vars "env=$environment region=$region";
    ;;

  "install-calico")
    ansible-playbook $ansible_verbose_arg ./playbooks/install_calico.yaml --extra-vars "env=$environment region=$region";
    ;;

  "namespace-creation")
    ansible-playbook $ansible_verbose_arg ./playbooks/create_namespace.yaml --extra-vars "env=$environment region=$region";
    ;;

  "install-ebs-storageclass")
    ansible-playbook $ansible_verbose_arg ./playbooks/install_ebs_gp3_storageclass.yaml --extra-vars "env=$environment region=$region";
    ;;

  "uninstall-ebs-storageclass")
    ansible-playbook $ansible_verbose_arg ./playbooks/uninstall_ebs_gp3_storageclass.yaml --extra-vars "env=$environment region=$region";
    ;;

  "bigbang_diff")
    ansible-playbook $ansible_verbose_arg ./playbooks/helm_diff.yaml --extra-vars "env=$environment region=$region";
    ;;

  "bigbang_upgrade")
    ansible-playbook $ansible_verbose_arg ./playbooks/helm_bigbang_upgrade.yaml --extra-vars "env=$environment region=$region";
    ;;

  *)
    echo -e ${bold}"Unknown action: $action"${normal}"\n";
    usage;
    exit 1;
    ;;
esac
