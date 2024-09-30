#!/bin/bash
# Runs a terminal in the given already-running container.
# Stores the last container for later retrieval using the 'last' parameter

script_dir=$(dirname $0)
exist_cntnr=$script_dir/data/exist_miopen_cntnr
wd=$HOME
touch $exist_cntnr
exist_tag=`cat $exist_cntnr`
test_tag=$exist_tag

if [ $# -ge 1 ]; then
	if [ ${1,,} == "last" ]; then
		use_last=1
	else
		test_tag=$1
	fi
else
	use_last=1
fi

if [ -n "$test_tag" ]; then
	cntnr_grep=`docker ps -a | grep -w "$test_tag"`
fi

if [ -n "$cntnr_grep" ]; then
	miopen_tag=$test_tag
	echo "Opening terminal in container '$miopen_tag'"
else
	if [ $use_last ]; then
		echo "Error: Container '$exist_cntnr' not found ('$test_tag')"
	else
		echo "Error: Container '$test_tag' was not found"
	fi
	echo "Usage: T-miopen-docker  <miopen_docker_tag [once]|[last [once]]>"
	echo "- to see a list of containers, run: 'docker ps -a | grep rocm/miopen'"
	if [ -n "$test_tag" ]; then
		echo "- run 'T-miopen-docker [last]' to open a new terminal in container  '$exist_tag'"
	fi
	exit 1
fi

if [ $# -lt 2 ]; then
	echo "$miopen_tag" > $exist_cntnr
fi

SU=
if [ "$HOSTNAME" = shemp ]; then
  SU=sudo
fi

# get a random name ala https://devops.stackexchange.com/questions/9810/how-to-get-the-next-friendly-name-that-docker-will-assign-to-the-container-it-wi
# DKR_NAME=$(curl -s https://frightanic.com/goodies_content/docker-names.php)

# try to open the terminal in user's repo home
if ! ($SU docker exec -w $wd/repos -it $miopen_tag /bin/bash); then
	if ! ($SU docker exec -w $wd -it $miopen_tag /bin/bash); then
		$SU docker exec -it $miopen_tag /bin/bash
	fi
fi
