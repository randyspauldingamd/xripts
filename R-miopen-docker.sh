#!/bin/bash
# Runs a container from the given docker image. ci images only.
# Stores the last image for later retrieval using the 'last' parameter

script_dir=$(dirname $0)
last_image_file=$script_dir/data/last_miopen_image
wd=$HOME
touch $last_image_file
test_tag=`cat $last_image_file`

if [ $# -eq 0 ]; then
	echo "Usage: R-miopen-docker  <miopen_docker_tag|last>  [once]"
	echo "- to see a list of images, run: 'docker image list | grep rocm/miopen'"
	if [ -n "$test_tag" ]; then
		echo "- run 'R-miopen-docker last' to run container  '$test_tag'  again"
	fi
	echo "- to prevent storing this image, add 'once' after the tag name"
	exit 1
fi

if [ ${1,,} = "last" ]; then
	use_last=1
else
	test_tag=$1
fi

if [ -n "$test_tag" ]; then
	image_grep=`docker image list | grep $test_tag`
fi

if [ -n "$image_grep" ]; then
	miopen_tag=$test_tag
	echo "Running container '$miopen_tag'"
else
	if [ $use_last ]; then
		echo "Error: file '$last_image_file' does not contain a valid image name ('$test_tag')"
	else
		echo "Error: docker image '$test_tag' was not found"
	fi
	exit 1
fi

if [ $# -lt 2 ]; then   # TODO: check for 'once'
	echo "$miopen_tag" > $last_image_file
fi

SU=
if [ "$HOSTNAME" = shemp ]; then
  SU=sudo
fi

# get a random name ala https://devops.stackexchange.com/questions/9810/how-to-get-the-next-friendly-name-that-docker-will-assign-to-the-container-it-wi
DKR_NAME=$(curl -s https://frightanic.com/goodies_content/docker-names.php)

# launch the container
$SU docker run -w $wd -v $wd:$wd -it --name $DKR_NAME --hostname $DKR_NAME --privileged --device=/dev/kfd --device=/dev/dri rocm/miopen:$miopen_tag
