#!/bin/bash
# Runs a container from the given docker image. ci images only.
# Stores the last image for later retrieval using the 'last' parameter

script_dir=$(dirname $0)
last_image_file=$script_dir/data/last_general_image
last_image_name=$script_dir/data/last_general_name
wd=$HOME
touch $last_image_file
test_tag=`cat $last_image_file`
touch $last_image_name
test_name=`cat $last_image_name`

if [ $# -lt 2 ] && [ "$1" -ne "last" ]; then
	echo "Usage: gR-docker  <docker_image  name|last>  [once]"
	echo "- to see a list of images, run: 'docker image list'"
	if [ -n "$test_tag" ]; then
		echo "- run 'gR-docker last' to run container  '$test_tag'  '$test_name'  again"
	fi
	echo "- to prevent storing this image, add 'once' after the tag name"
	exit 1
fi

if [ ${1,,} = "last" ]; then
	use_last=1
else
	test_tag=$1
	test_name=$2
fi

if [ -n "$test_tag" ]; then
	image_grep=`docker image list | grep $test_tag`
fi

if [ -n "$image_grep" ]; then
	miopen_tag=$test_tag
	echo "Running container based on image '$miopen_tag'"
else
	if [ $use_last ]; then
		echo "Error: file '$last_image_file' does not contain a valid image name ('$test_tag')"
	else
		echo "Error: docker image '$test_tag' was not found"
	fi
	exit 1
fi

echo "$miopen_tag" > $last_image_file
echo "$test_name" > $last_image_name

SU=
if [ "$HOSTNAME" = shemp ]; then  SU=sudo;  fi

# get a random name ala https://devops.stackexchange.com/questions/9810/how-to-get-the-next-friendly-name-that-docker-will-assign-to-the-container-it-wi
DKR_NAME=$(curl -s https://frightanic.com/goodies_content/docker-names.php)

bwd=${wd}
if [ -d "${wd}/repos" ]; then
	bwd=${wd}/repos
fi

# launch the container
#$SU docker run -w $wd/repos -v $wd:$wd -it --name $DKR_NAME --hostname $DKR_NAME --privileged --device=/dev/kfd --device=/dev/dri $miopen_tag); then
$SU docker run -w $bwd -v $wd:$wd -it --name $test_name --hostname $test_name --privileged --device=/dev/kfd --device=/dev/dri $miopen_tag  && exit 0
$SU docker run -w $bwd -v $wd:$wd -it --name $DKR_NAME --hostname $DKR_NAME --privileged --device=/dev/kfd --device=/dev/dri $miopen_tag

echo "Failed to launch container!"
exit 1
