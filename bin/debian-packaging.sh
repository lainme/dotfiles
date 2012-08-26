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
    echo "-d DPUT_REPO      -   Optional. Remote repo. Default is ppa:USERNAME/sandbox"
    echo "-s SOURCE_DIR     -   Optional. Directory where source exsits, default is ~/Downloads/PACKAGE_NAME. Used if misc build is enabled"
    echo "-u FLAG           -   Optional. If not zero, upload to the specified remote repo. Default is 0"
    echo "-l FLAG           -   Optional. If not zero, locally build the package using pbuilder-dist. Default is 0"
    echo "-o FLAG           -   Optional. If not zero, upload .orig.tar.gz. Default is 0"
    echo "-p FLAG           -   Optional. If not zero, do not commmit to git. Default is 0"
    echo "-m FLAG           -   Optional. If not zero, invoke non-git build (misc build). Default is 0"
    echo "-h                -   show this help"
}

function set_build_dir(){
    #create build dir
    rm -rf $build_dir
    mkdir -p $build_dir

    #obtain source files
    if [ "$misc_build" != "0" ];then
        cp -r $source_dir $build_dir/$package_name
    else
        git clone $GITBASE/$package_name.git -b $git_branch $build_dir/$package_name
    fi

    #create orig
    cd $build_dir
    tar --exclude="debian" -czf "$package_name.orig.tar.gz" $package_name

    #prepare packaging dirs
    for release in ${releases[*]};do
        mkdir -p $build_dir/$release
    done
}

function set_version(){
    #change dir
    cd $build_dir/$package_name

    #major-version
    major_version=`sed -n "1s/.*(\([.0-9]*\).*/\1/p" debian/changelog`

    #minor-version
    if [ "$misc_build" != "0" ];then
        read -p "Minor version: " minor_version
        minor_version="-$minor_version"
    else
        minor_version=`git log -n 1 --date=short --pretty=format:"git%ad.%h" | sed "s/-//g"`
        minor_version="+$minor_version"
    fi
    version="$major_version$minor_version~$USERNAME"
    read -e -i $version -p "Confirm version: " version
}

function set_changelog(){
    #change dir
    cd $build_dir/$package_name

    #timestamp
    timestamp=`date -R`

    #change log
    changelog="$package_name ($version) unstable; urgency=low\n\
\n\
  * [Enter comment here]\n\
\n\
 -- $USERNAME <$USEREMAIL>  $timestamp\n"

    sed -i "1i $changelog" debian/changelog

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
    for release in ${releases[*]};do
        #copy files
        cp -r $build_dir/$package_name $build_dir/$release/$package_name-$major_version

        #copy orig
        orig_version=`echo "$version" | sed "s/\(.*\)-.*/\1/"`
        cp "$build_dir/$package_name.orig.tar.gz" $build_dir/$release/$package_name"_"$orig_version~$release".orig.tar.gz"
        
        #change dir
        cd $build_dir/$release/$package_name-$major_version

        #modify
        sed -i "s|\(~$USERNAME\)\(.*\)unstable|\1~$release\2$release|" "debian/changelog"

        #build
        if [ "$has_orig" != "0" ];then
            debuild -S -sa
        else
            debuild -S -sd
        fi
    done
}

function dput_upload(){
    #check
    if [ "$upload" == "0" ];then
        return
    fi

    #uplaod
    for release in ${releases[*]};do
        cd $build_dir/$release/
        dput $dput_repo *.changes
    done
}

function local_build(){
    #check
    if [ "$local_build" == "0" ];then
        return
    fi

    #uplaod
    for release in ${releases[*]};do
        if [ ! -f $HOME/pbuilder/$release-base.tgz ];then
            pbuilder-dist $release create
        fi
        cd $build_dir/$release/
        pbuilder-dist $release build *.dsc
    done
}

#--------------------------------------------------
#main
#--------------------------------------------------
#script configuration
USERNAME=lainme #username
USEREMAIL=lainme993@gmail.com #user email
GITBASE=git@github.com:$USERNAME #git base repo url
OUTPUT=$HOME/build #output directory

#default values of options
config_file=""
package_name=""
git_branch="master"
releases=("`lsb_release -cs`")
dput_repo="ppa:$USERNAME/sandbox"
source_dir=""
upload=0
local_build=0
has_orig=0
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
        -0) has_orig=$2;shift 2;;
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

if [ ( "$misc_build" != "0" ) -a ( -z $source_dir ) ];then
    source_dir=$HOME/Downloads/$package_name
fi

build_dir=$OUTPUT/$package_name


#pacakging
set_build_dir #set build directory
set_version #set version number
set_changelog #set changelog
git_commit #commit to git
deb_packaging #debian packaging
dput_upload #upload to remote repo
local_build #locally build package
