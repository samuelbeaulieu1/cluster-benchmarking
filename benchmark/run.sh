#/bin/sh

BUILD=false
APP_URL=""

while getopts a:b flag;
do
    case "${flag}" in
        b) BUILD=true;;
        a) APP_URL=${OPTARG};;
    esac
done

# Build docker image if not set or if manual build
if [[ $BUILD = true ]] || [[ "$(sudo docker images -q flask-app-test 2> /dev/null)" == "" ]]; then
    sudo docker build -t flask-app-test:latest .
fi

# Run test with app url as input to script
sudo docker run -e "APP_URL=$APP_URL" flask-app-test
