#!/bin/bash
#debian packaging for varies of releases. currently design for Git
#TODO: bzr support

#--------------------------------------------------
#functions
#--------------------------------------------------
function show_help(){
    echo "Description: build debian package and upload to launchpad"
    echo "Usage: debian-packaging [options]"
    echo "-c CONFIG_FILE    -   Optional. Specify the configuration file for a build"
    echo "-n PACKAGE_NAME   -   Required. Specify the package name."
    echo "-b GIT_BRANCH     -   Optional. Specify which branch to use. Default is master"
    echo "-v VERSION_SCHEME -   Optional. Specify how to determine minor version. Default is 'git'"
    echo "-r RELEASES       -   Optional. Specify the releases to build. Default is the release of current system"
    echo "-o OUTOUT_DIR     -   Optional. specify the output directory. Default is ~/build"
    echo "-d DPUT_REPO      -   Optional. Specify the remote repo. Default is ppa:USERNAME/sandbox"
    echo "-u                -   Optional. If set, upload to the specified remote repo"
    echo "-l                -   Optional. If set, locally build the package using pbuilder-dist"
    echo "-a                -   Optional. If set, do not upload .orig.tar.gz"
    echo "-t                -   Optional. If set, do not commmit to git"
    echo "-h                -   show this help"
}

function set_build_dir(){
    #create build dir
    rm -rf $build_dir
    mkdir -p $build_dir

    #clone source files
    git clone $GITBASE/$package_name.git -b $git_branch $build_dir/$package_name

    #create orig
    cd $build_dir
    tar --exclude=".git" --exclude=".gitignore" --exclude="debian" -czf "$package_name.orig.tar.gz" $package_name

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
    if [ "$version_scheme" == "manual" ];then
        read -p "Minor version: " minor_version
        minor_version="-$minor_version"
    elif [ "$version_scheme" == "git" ];then
        minor_version=`git log -n 1 --date=short --pretty=format:"git%ad.%h" | sed "s/-//g"`
        minor_version="+$minor_version"
    fi
    version="$major_version$minor_version~$USERNAME"
    read -e -i $version -p "Confirm version: " version
}

function set_changelog(){
    #change dir
    cd $build_dir/$package_name

    #read comment
    comment=`git log -n 1 --pretty=format:%s`

    #timestamp
    timestamp=`date -R`

    #change log
    changelog="$package_name ($version) unstable; urgency=low\n\
\n\
  * $comment\n\
\n\
 -- $USERNAME <$USEREMAIL>  $timestamp\n"

    sed -i "1i $changelog" debian/changelog

    $EDITOR debian/changelog
}

function git_commit(){
    #check
    if [ "$no_commit" == "1" ];then
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
        rm -rf .git .gitignore
        sed -i "s|\(~$USERNAME\)\(.*\)unstable|\1~$release\2$release|" "debian/changelog"

        #build
        if [ "$has_orig" == "1" ];then
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

#default values of options
config_file=""
package_name=""
git_branch="master"
version_scheme=manual
releases=("`lsb_release -cs`")
output_dir=$HOME/build
dput_repo="ppa:$USERNAME/sandbox"
upload=0
local_build=0
has_orig=1
no_commit=0

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
        -v) version_scheme=$2;shift 2;;
        -r) releases=$2;shift 2;;
        -o) output_dir=$2;shift 2;;
        -d) dput_repo=$2;shift 2;;
        -u) upload=1;shift 1;;
        -l) local_build=1;shift 1;;
        -a) has_orig=0;shift 1;;
        -t) no_commit=1;shift 1;;
        -h) show_help;shift 1;;
        *) echo "option $1 not recognizable, type -h to see help list";exit;;
    esac
done

#check arguments
if [ -z $package_name ];then
    echo "Option missing: use -n PACKAGE_NAME to specify the package name"
    exit
fi

build_dir=$output_dir/$package_name

#pacakging
set_build_dir #set build directory
set_version #set version number
set_changelog #set changelog
git_commit #commit to git
deb_packaging #debian packaging
dput_upload #upload to remote repo
local_build #locally build package
