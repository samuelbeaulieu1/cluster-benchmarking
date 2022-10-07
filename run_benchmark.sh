#/bin/sh

BUILD=false

while getopts b flag;
do
    case "${flag}" in
        b) BUILD=true;;
    esac
done

# Get credentials from ~/.aws/credentials if env vars are not set
if [[ -z $AWS_ACCESS_KEY_ID ]] || [[ -z $AWS_SECRET_ACCESS_KEY ]] || [[ -z $AWS_SESSION_TOKEN ]]; then
    values=$(awk -F '=' '{
        if ($1 != "[default]") {
            print $0;
        }
    }' ~/.aws/credentials)

    for val in $values
    do
        IFS='='
        read -a name_with_value <<< $val
        if [[ ${name_with_value[0]} == "aws_access_key_id" ]]; then 
            AWS_ACCESS_KEY_ID=${name_with_value[1]} 
        fi 
        if [[ ${name_with_value[0]} == "aws_secret_access_key" ]]; then 
            AWS_SECRET_ACCESS_KEY=${name_with_value[1]} 
        fi 
        if [[ ${name_with_value[0]} == "aws_session_token" ]]; then 
            AWS_SESSION_TOKEN=${name_with_value[1]} 
        fi 
    done
fi

# Build docker container for terraform


# Terraform apply


# Build docker image if not set or if manual build
if [[ $BUILD = true ]] || [[ "$(sudo docker images -q flask-app-test 2> /dev/null)" == "" ]]; then
    sudo docker build -f ./benchmark/Dockerfile -t flask-app-test:latest \
        --build-arg AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
        --build-arg AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
        --build-arg AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} \
        ./benchmark
fi

# Run test with app url as input to script
sudo docker run flask-app-test

# Terraform destroy
