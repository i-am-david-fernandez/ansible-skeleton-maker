#!/bin/bash

## Create a file/directory framework for Ansible use.

force="false"
root_dir=`pwd`
roles_subdir="roles"

echo_error()
{
    echo -ne "\e[1;31;40m ERROR:\e[m "$1
}

echo_info()
{
    echo -ne "\e[1;36;40m INFO:\e[m "$1
}


init_base()
{
    pushd `pwd` > /dev/null 2>&1

    if [ -d "$root_dir" ]
    then
        if [ "$force" != "true" ]
        then
            echo_error "Root directory $root_dir already exists and will not be overwritten.\n"
            exit 1
        fi
    else
        echo_info "Creating root directory $root_dir\n"
        mkdir -p $root_dir
    fi

    cd $root_dir

    ## Create empty staging and production hosts file
    touch staging
    touch production

    ## Create group variables directory
    mkdir -p group_vars

    ## Create host variables directory
    mkdir -p host_vars

    ## Create a playbook directory
    mkdir -p playbooks
    pushd `pwd` > /dev/null 2>&1
    cd playbooks
    ln -sf ../$roles_subdir ./
    popd > /dev/null 2>&1

    ## Create top-level role directory
    mkdir -p $roles_subdir

    popd > /dev/null 2>&1
}


init_role()
{
    local role_name=$1

    local roles_dir="$root_dir/$roles_subdir"

    if [ ! -d "$roles_dir" ]
    then
        echo_error "Error! Expected base roles directory $roles_dir does not exist. Cannot proceed.\n"
        exit 1
    fi

    pushd `pwd` > /dev/null 2>&1

    cd $roles_dir

    if [ -d "$role_name" ]
    then
        if [ "$force" != "true" ]
        then
            echo_error "Error! A role named $role_name already exists. Cannot proceed.\n"
            exit 1
        fi
    fi

    echo_info "Creating role [$role_name]\n"

    mkdir -p $role_name
    cd $role_name

    ## Create files directory
    mkdir -p files

    ## Create tasks directory and empty main task file
    mkdir -p tasks
    touch tasks/main.yml

    ## Create templates directory
    mkdir -p templates

    ## Create variables directory and empty main variables file
    mkdir -p vars
    touch vars/main.yml

    popd > /dev/null 2>&1
}

showUsage()
{
    echo "
Arguments:
 --root <root_dir>         : Specify optional root directory (defaults to current directory).
 -b/--base                 : Create base structure.
 -r/--role <name>          : Create skeleton for role named <name>.
 --force                   : Forcibly overwrite existing targets.
"
}


commandline_arguments=`getopt --options br: --longoptions force,root:,base,role: -- $*`
if [ $? != 0 ] || [ -z "$*" ]
then
    showUsage
    exit 1
fi

eval set -- "$commandline_arguments"

while true
do
    ##echo "[$1]"

    case "$1" in

        "--force" )
            force="true"
            ;;
        "--root" )
            root_dir=$2
            shift
            ;;
        "-b"|"--base" )
            init_base
            ;;
        "-r"|"--role" )
            role_name=$2
            shift
            init_role $role_name
            ;;
        "--")
            shift
            break
            ;;
        *)
            echo "Unknown option [$1]"
            showUsage
            exit 1
            ;;
    esac
    shift
done
