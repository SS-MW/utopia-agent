#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Usage: ./lambda-fn-build.sh <function name>"
    exit 1
fi

LAMBDA_NAME=$1
CONTROLLER_ROOT="${LAMBDA_NAME}Controller"

echo -e "\n\n[>] Clearing workspace..."
sudo rm -rf "./$LAMBDA_NAME"

echo -e "[>] Initialzing SAM sample app...\n"
echo 1 | sam init --runtime ruby2.5 --name "$LAMBDA_NAME"

echo -e "[>] Renaming sample app root..."
mv "./$LAMBDA_NAME/hello_world" "./$LAMBDA_NAME/$CONTROLLER_ROOT"

echo -e "[>] Copying gem file template to app root..."
cp "./gemfile_template" "./$LAMBDA_NAME/$CONTROLLER_ROOT/Gemfile"

echo -e "[>] Copying gem_miner.sh to app root..."
cp "./gem_miner.sh" "./$LAMBDA_NAME/$CONTROLLER_ROOT"

echo -e "[>] Copying rest template to app root..."
cp "./rest_template.rb" "./$LAMBDA_NAME/$CONTROLLER_ROOT/app.rb"

echo -e "[>] Copying lambda template to app root..."
cp "./template.yaml" "./$LAMBDA_NAME/template.yaml"

echo -e "[>] Copying deploy script to app root..."
cp "./deply.sh" "./$LAMBDA_NAME"

echo -e "[>] Moving to app root..."
cd "$LAMBDA_NAME/$CONTROLLER_ROOT"

echo -e '[>] Running docker container and mining gems...\n'
docker run -v "$PWD":/var/task lambci/lambda:build-ruby2.5 /bin/bash gem_miner.sh

echo -e '[>] Updating rest template...'
sed -i "s/Hello World/$LAMBDA_NAME/g" ../template.yaml
sed -i "s/HelloWorld/$LAMBDA_NAME/g"  ../template.yaml
sed -i "s/hello_world/$CONTROLLER_ROOT/g" ../template.yaml

echo -e "[>] Moving to project root..."
cd ../

echo -e "[>] Invoking lambda with events.json...\n"
sam local invoke --event events/event.json --docker-network host
