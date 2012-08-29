#!/bin/bash
#debian packaging for varies of releases. currently design for Git
#TODO: 
# 1. bzr support

#--------------------------------------------------
#functions
#--------------------------------------------------
function show_help(){
    echo "Description: build debian package and upload to launchpad"
    echo "Usage: debian-packaging [options]"
    echo "-c CONFIG_FILE    -   Optional. Configuration file for a build"
    echo "-n PACKAGE_NAME   -   Required. Package name."
    echo "-b GIT_BRANCH     -   Optional. Which branch to use. Default is master"
    echo "-r RELEASES       -   Optional. Releases to build. Default is the release of current system"
    echo "-d DPUT_REPO      -   Optional. Remote repos. Default is ppa:USERNAME/sandbox only"
    echo "-s SOURCE_DIR     -   Optional. Directory where source exsits, default is ~/Downloads/PACKAGE_NAME. Used if misc build enabled"
    echo "-u FLAG           -   Optional. If not zero, upload to the specified remote repo. Default is 0"
    echo "-l FLAG           -   Optional. If not zero, locally build the package using pbuilder-dist. Default is 0"
    echo "-a FLAG           -   Optional. If not zero, do not upload .orig.tar.gz. Default is 1"
    echo "-p FLAG           -   Optional. If not zero, do not commmit to git. Default is 0"
    echo "-m FLAG           -   Optional. If not zero, invoke non-git build (misc build). Default is 0"
    echo "-h                -   show this help"
}

function set_build_dir(){
    #create build dir
    rm -rf $build_dir
    mkdir -p $build_dir
    cd $build_dir

    #obtain source files
    if [ "$misc_build" != "0" ];then
        cp -r $source_dir $build_dir/$package_name
    else
        git clone $GITBASE/$package_name.git -b $git_branch $build_dir/$package_name
    fi

    #prepare packaging dirs
    for release in ${releases[*]};do
        mkdir -p $build_dir/$release
    done
}

function set_changelog(){
    #change dir
    cd $build_dir/$package_name

    #--------------------------------------------------
    #version
    #--------------------------------------------------
    #prefix, old major and minor version
    prefix=`sed -n -r "1s/.*\((.*:).*/\1/p" debian/changelog`
    major_version=`sed -n -r "1s/.*\((.*:|)([.0-9]*).*/\2/p" debian/changelog`
    minor_version=`sed -n -r "1s/.*\((.*:|)[.0-9]*(.*)\).*/\2/p;1s/~lainme.*//p" debian/changelog`

    #git minor version
    if [ "$misc_build" == "0" ];then
        minor_version=`git log -n 1 --date=short --pretty=format:"git%ad.%h" | sed "s/-//g"`
        minor_version="+$minor_version"
    fi

    #set version
    version="$major_version$minor_version~$USERNAME"

    #confirm version
    read -e -i $version -p "Confirm version: " version

    #--------------------------------------------------
    #changelog
    #--------------------------------------------------
    #set timestamp
    timestamp=`date -R`

    #change log
    changelog="$package_name ($prefix$version) unstable; urgency=low\n\
\n\
  * [Enter comment here]\n\
\n\
 -- $USERNAME <$USEREMAIL>  $timestamp\n"

    sed -i "1i $changelog" debian/changelog

    #confirm changelog
    $EDITOR debian/changelog
}

function git_commit(){
    #check
    if [ "$is_commit" == "0" -o "$misc_build" != "0" ];then
        return
    fi

    #commit
    cd $build_dir/$package_name
    git commit -a -m "Debian packaging for version $version"
    git push origin $git_branch
}

function deb_packaging(){
    #change package name
    cd $build_dir
    mv $package_name $package_name-$major_version

    #generate .orig.tar.gz
    tar --exclude=".git" --exclude=".gitignore" --exclude="debian" -czf $package_name"_"$major_version".orig.tar.gz" $package_name-$major_version

    #build
    for release in ${releases[*]};do
        #copy files and orig
        cp -r $build_dir/$package_name-$major_version $build_dir/$release/
        cp $build_dir"/"$package_name"_"$major_version".orig.tar.gz" $build_dir/$release/
        
        #change dir
        cd $build_dir/$release/$package_name-$major_version

        #modify
        if [ "$misc_build" == "0" ];then
            rm -rf .git .gitignore
        fi
        sed -i "s|\(~$USERNAME\)\().*\)unstable|\1~$release\2$release|" "debian/changelog"

        #build
        if [ "$no_orig" != "0" ];then
            debuild -S -sd
        else
            debuild -S -sa
        fi
    done
}

function dput_upload(){
    #check
    if [ "$upload" == "0" ];then
        return
    fi

    #upload
    for release in ${releases[*]};do
        for repo in ${dput_repo[*]};do
            if [ "$repo" == "local" ];then
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
    export DEB_BUILD_OPTIONS=nocheck

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
USERNAME=lainme #username
USEREMAIL=lainme993@gmail.com #user email
GITBASE=git@github.com:$USERNAME #git base repo url
OUTPUT_DIR=$HOME/build #output directory
PBUILDER_DIR=$HOME/pbuilder #pbuilder-dist directory
PBUILDER_ARCH=`uname -i` #archtecture used for pbuilder (default native)

#default values of options
config_file=""
package_name=""
git_branch="master"
releases=("`lsb_release -cs`")
dput_repo=("ppa:$USERNAME/sandbox")
source_dir=""
upload=0
local_build=0
no_orig=1
is_commit=0
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
        -c) config_file=$2;source $2;shift 2;; #source config file
        -n) package_name=$2;shift 2;;
        -b) git_branch=$2;shift 2;;
        -r) releases=$2;shift 2;;
        -d) dput_repo=$2;shift 2;;
        -s) source_dir=$2;shift 2;;
        -u) upload=$2;shift 2;;
        -l) local_build=$2;shift 2;;
        -a) no_orig=$2;shift 2;;
        -p) no_commit=$2;shift 2;;
        -m) misc_build=$2;shift 2;;
        -h) show_help;shift 2;;
        *) echo "option $1 not recognizable, type -h to see help list";exit;;
    esac
done

#check arguments
if [ -z $package_name ];then
    echo "Option missing: use -n PACKAGE_NAME to specify the package name"
    exit
fi

if [ "$misc_build" != "0" -a "t$source_dir" == "t" ];then
    source_dir=$HOME/Downloads/$package_name
fi

#set build directory
build_dir=$OUTPUT_DIR/$package_name

#pacakging
set_build_dir #set build directory
set_changelog #set changelog
git_commit #commit to git
deb_packaging #debian packaging
local_build #locally build package
dput_upload #upload to remote repo
