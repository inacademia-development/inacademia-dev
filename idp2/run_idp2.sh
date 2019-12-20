#! /bin/bash
IMAGE_TAG=inacademia/idp2:v1
CONTAINER_NAME=inacademia-idp2

# Steup the netwerk if needed
if [ ! "$(docker network ls | grep inacademia.local)" ]; then
  echo "Creating inacademia.local network ..."
  ../dockernet.sh
else
  echo "inacademia.local network exists."
fi
# Build the docker image if needed
if [[ "$(docker images -q $IMAGE_TAG 2> /dev/null)" == "" ]]; then
  echo "Creating $IMAGE_TAG docker container ..."
  docker build -t $IMAGE_TAG .
else
  echo "$IMAGE_TAG docker container exists..."
fi

# Start SSP IDP
docker start -i $CONTAINER_NAME || docker run -it \
    --name $CONTAINER_NAME \
    --net inacademia.local \
    --ip 172.172.172.200 \
    --add-host=svs.inacademia.local:172.172.172.1 \
    --add-host=op.inacademia.local:172.172.172.2 \
    --add-host=rp.inacademia.local:172.172.172.100 \
    --add-host=idp.inacademia.local:172.172.172.200 \
    --hostname idp.inacademia.local \
    --expose 80 \
    --expose 443 \
    --volume $PWD/config/metadata:/var/www/simplesamlphp/metadata \
    $IMAGE_TAG