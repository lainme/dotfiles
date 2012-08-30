#!/bin/bash
# Debian packaging for varies of releases. Currently design for Git
# TODO: 
# 1. bzr support

#--------------------------------------------------
#functions
#--------------------------------------------------
function show_help(){
    echo "Description: build debian package and upload to launchpad or local repository"
    echo "Usage: debian-packaging [options]"
    echo "The -c/--config option should be given first, then you can override the options in config file"
    echo "-c --config   CONFIG_FILE     - Optional. Configuration file for a build"
    echo "-n --name     PACKAGE_NAME    - Required. Package name."
    echo "-b --branch   GIT_MAIN_BRANCH - Optional. Which branch to use. Default is master"
    echo "-u --upstream GIT_ORIG_BRANCH - Optional. Which branch to use as upstream. Default is upstream"
    echo "-r --releases RELEASES        - Optional. Build for which system versions. Default is the version of current system"
    echo "-d --dput     DPUT_REPO       - Optional. Remote repository. If not empty, upload to the specified repositories using dput"
    echo "-s --source   SOURCE_DIR      - Optional. Directory where source exists, default is ~/Downloads/PACKAGE_NAME. Used if misc build enabled"
    echo "-o --orig     ORIG_FILE       - Optional. Path of .orig file, default is created by program"
    echo "-l --pbuilder FLAG            - Optional. If not zero, locally build the package using pbuilder-dist. Default is 0"
    echo "-a --alter    FLAG            - Optional. If not zero, do not upload .orig.tar.*. Default is 1"
    echo "-p --commit   FLAG            - Optional. If not zero, commit to git. Default is 0"
    echo "-t --tag      FLAG            - Optional. If not zero, add tag to git. Default is 0"
    echo "-m --misc     FLAG            - Optional. If not zero, invoke non-git build (misc build). Default is 0"
    echo "-h --help                     - show this help"
}

function set_build_dir(){
    #create build directory
    rm -rf $build_dir
    mkdir -p $build_dir
    cd $build_dir

    #obtain source files
    if [ "$misc_build" != "0" ];then
        cp -r $source_dir $build_dir/$package_name
    else
        git clone $GITBASE/$package_name.git -b $git_main_branch $build_dir/$package_name
    fi

    #prepare packaging directories
    for release in ${releases[*]};do
        mkdir -p $build_dir/$release
    done
}

function set_changelog(){
    #change directory
    cd $build_dir/$package_name

    #--------------------------------------------------
    #changelog
    #--------------------------------------------------
    #prepare version
    version=`sed -n "1s|.*(\(.*\)).*|\1|;1s|~$USERNAME.*||p" debian/changelog`
    version=$version~$USERNAME

    if [ "$misc_build" == "0" ];then
        git_version=`git log origin/$git_orig_branch -n 1 --date=short --pretty=format:"git%ad.%h" | sed "s/-//g"`
        version=`echo $version | sed "s|git[.0-9a-zA-Z]*|$git_version|"`
    fi

    #set time stamp
    timestamp=`date -R`

    #change log
    changelog="$package_name ($version) unstable; urgency=low\n\
\n\
  * [Enter comment here]\n\
\n\
 -- $USERNAME <$USEREMAIL>  $timestamp\n"

    sed -i "1i $changelog" debian/changelog

    #confirm changelog
    $EDITOR debian/changelog

    #--------------------------------------------------
    #version
    #--------------------------------------------------
    version=`sed -n -r "1s|.*\((.*:\|)(.*)\).*|\2|p" debian/changelog`
    major_version=`echo $version | sed -n -r "s/([^-]*).*/\1/p"`
}

function git_commit(){
    #check
    if [ "$misc_build" != "0" ];then
        return
    fi

    if [ "$is_commit" == "0" -a "$is_tag" == "0" ];then
        return
    fi

    #change directory
    cd $build_dir/$package_name

    #commit
    if [ "$is_commit" != "0" ];then
        git commit -a -m "Debian packaging for version $version"
    fi

    #tag
    if [ "$is_tag" != "0" ];then
        git tag -a debian/$major_version -m "Release version $major_version"
    fi

    #push to remote
    git push origin $git_main_branch
}

function deb_packaging(){
    #change package name
    cd $build_dir
    mv $package_name $package_name-$major_version

    #generate .orig.tar.*
    if [ -z $orig_file ];then
        tar --exclude=".git" --exclude=".gitignore" --exclude="debian" -czf \
            ${package_name}_${major_version}.orig.tar.gz $package_name-$major_version
    else
        cp $orig_file .
    fi

    #build
    for release in ${releases[*]};do
        #copy files and orig
        cp -r $build_dir/$package_name-$major_version $build_dir/$release/
        cp ${build_dir}/${package_name}_${major_version}.orig.tar.* $build_dir/$release/
        
        #change directory
        cd $build_dir/$release/$package_name-$major_version

        #modify
        if [ "$misc_build" == "0" ];then
            rm -rf .git .gitignore
        fi
        sed -i "1s|\(~$USERNAME\)\().*\)unstable|\1~$release\2$release|" "debian/changelog"

        #build
        if [ "$no_orig" != "0" ];then
            debuild -S -sd
        else
            debuild -S -sa
        fi
    done
}

function dput_upload(){
    for release in ${releases[*]};do
        for repo in ${dput_repo[*]};do
            if [ "$repo" == "$LOCAL_REPO" ];then
                cd $PBUILDER_DIR"/"$release"_result"
                changes_name=$package_name"_"$version"~"$release"_"$PBUILDER_ARCH".changes"
            else
                cd $build_dir/$release/
                changes_name=$package_name"_"$version"~"$release"_source.changes"
            fi

            dput $repo $changes_name
        done
    done
}

function local_build(){
    #check
    if [ "$local_build" == "0" ];then
        return
    fi

    #do not check
    export DEB_BUILD_OPTIONS=$BUILD_OPTIONS

    for release in ${releases[*]};do
        #create package
        if [ ! -f $PBUILDER_DIR/$release-base.tgz ];then
            pbuilder-dist $release $PBUILDER_ARCH create
        fi

        #build
        cd $build_dir/$release/
        pbuilder-dist $release $PBUILDER_ARCH build $package_name"_"$version"~"$release".dsc"

        #sign package
        cd $PBUILDER_DIR"/"$release"_result"
        debsign $package_name"_"$version"~"$release"_"$PBUILDER_ARCH".changes"
    done
}

#--------------------------------------------------
#main
#--------------------------------------------------
#script configuration
USERNAME=lainme #user name
USEREMAIL=lainme993@gmail.com #user email
GITBASE=git@github.com:$USERNAME #git base repository URL
OUTPUT_DIR=$HOME/build #output directory
PBUILDER_DIR=$HOME/pbuilder #pbuilder-dist directory
PBUILDER_ARCH=`uname -i` #architecture used for pbuilder (default native)
LOCAL_REPO="local" #name of local repository (defined in .dput.cf)
BUILD_OPTIONS=nocheck #do not check

#default values of options
config_file=""
package_name=""
git_main_branch="master"
git_orig_branch="upstream"
releases=("`lsb_release -cs`")
dput_repo=("")
source_dir=""
orig_file=""
local_build=0
no_orig=1
is_commit=0
is_tag=0
misc_build=0

#other global variables
build_dir=""
version=""
major_version=""

#parse command line arguments
if [ $# -eq 0 ];then
    show_help
    exit
fi

while [ $# -gt 1 ];do
    case $1 in
        -c|--config)    config_file=$2;source $2;shift 2;; #source config file
        -n|--name)      package_name=$2;shift 2;;
        -b|--branch)    git_main_branch=$2;shift 2;;
        -u|--upstream)  git_orig_branch=$2;shift 2;;
        -r|--releases)  releases=$2;shift 2;;
        -d|--dput)      dput_repo=$2;shift 2;;
        -s|--source)    source_dir=$2;shift 2;;
        -o|--orig)      orig_file=$2;shift 2;;
        -l|--pbuilder)  local_build=$2;shift 2;;
        -a|--alter)     no_orig=$2;shift 2;;
        -p|--commit)    is_commit=$2;shift 2;;
        -t|--tag)       is_tag=$2;shift 2;;
        -m|--misc)      misc_build=$2;shift 2;;
        -h|--help)      show_help;shift 2;;
        *) echo "option $1 not recognizable, type -h to see help list";exit;;
    esac
done

#check arguments
if [ -z $package_name ];then
    echo "Option missing: use -n PACKAGE_NAME to specify the package name"
    exit
fi

#set source directory
if [ "$misc_build" != "0" -a "t$source_dir" == "t" ];then
    source_dir=$HOME/Downloads/$package_name
fi

#set build directory
build_dir=$OUTPUT_DIR/$package_name

#packaging
set_build_dir #set build directory
set_changelog #set changelog
git_commit #commit to git
deb_packaging #debian packaging
local_build #locally build package
dput_upload #upload to remote repository
