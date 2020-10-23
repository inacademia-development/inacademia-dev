#! /bin/bash
source svs.cnf
IMAGE_TAG=${IMAGE_NAME}:${IMAGE_VERSION}_${DOCKER_VERSION}
CONTAINER_NAME=${IMAGE_NAME/\//_}

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Building Container: $CONTAINER_NAME "
echo "Using SATOSA version: $SATOSA_VERSION "
echo "And SVS version: $SVS_VERSION "
echo "Outputting: $IMAGE_TAG "
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

# As the build command is being called, we assume we need to build a new image.
# To be sure we therefor first remove existign ones
if [[ "$(docker images -q $IMAGE_TAG 2> /dev/null)" != "" ]]; then
  echo "Removing existing $IMAGE_TAG docker container ..."
  docker rmi -f $IMAGE_TAG
fi

echo "Building  docker container $IMAGE_TAG ..."
# Build the docker image
docker build -t $IMAGE_TAG \
    --build-arg SATOSA_VERSION=${SATOSA_VERSION} \
    --build-arg SVS_VERSION=${SVS_VERSION} \
    --no-cache .

# find the location of configs in current directory structure
RUN_DIR=$PWD
CONFIG_DIR="$RUN_DIR/config"

# Remove existing container
docker rm $CONTAINER_NAME || echo "$CONTAINER_NAME not found, can't remove"

# Create SVS
docker create -it \
    --name $CONTAINER_NAME \
    --env PROXY_PORT=80 \
    --env SATOSA_STATE_ENCRYPTION_KEY=1fa0dafd36d9d2c8401b943sk4kwde954e2016cf3f37fa1f67bbffe6c4f2f78e \
    --env SATOSA_USER_ID_HASH_SALT=6f692915a7df20d9d4be17a70djdieff04585b0ab231825b7a15ed5d6140aa1e \
    -v $CONFIG_DIR/production:/var/svs \
    -v $CONFIG_DIR/cdb:/etc/cdb \
    -v /etc/passwd:/etc/passwd:ro   \
    -v /etc/group:/etc/group:ro \
    -v $PWD/workdir:/opt/workdir \
    -e DATA_DIR=/var/svs \
    -w /var/svs \
    --net inacademia-dev_inacademia \
    --ip 172.21.10.2 \
    --add-host=svs.inacademia.local:172.21.10.2 \
    --add-host=op.inacademia.local:172.21.10.3 \
    --add-host=mdq.inacademia.local:172.21.10.4 \
    --add-host=rp.inacademia.local:172.21.10.100 \
    --add-host=idp1.inacademia.local:172.21.10.201 \
    --add-host=idp2.inacademia.local:172.21.10.202 \
    --add-host=idp3.inacademia.local:172.21.10.203 \
    --hostname svs.inacademia.local \
    --expose 80 \
    --expose 443 \
    $IMAGE_TAG

