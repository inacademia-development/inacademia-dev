#! /bin/bash
IMAGE_TAG=inacademia/svs:v1

# Build the docker image if needed
if [[ "$(docker images -q $IMAGE_TAG 2> /dev/null)" == "" ]]; then
  docker build -t $IMAGE_TAG .
fi

# Start SVS
docker run -it \
	--env PROXY_PORT=80 \
	--env SATOSA_STATE_ENCRYPTION_KEY=1fa0dafd36d9d2c8401b943sk4kwde954e2016cf3f37fa1f67bbffe6c4f2f78e \
	--env SATOSA_USER_ID_HASH_SALT=6f692915a7df20d9d4be17a70djdieff04585b0ab231825b7a15ed5d6140aa1e \
	-v /home/niels/dev/inacademia-dev/svs/config/production:/var/svs \
	-v /home/niels/dev/inacademia-dev/svs/config/cdb:/etc/cdb \
	-v /etc/passwd:/etc/passwd:ro   \
	-v /etc/group:/etc/group:ro \
	-e DATA_DIR=/var/svs \
	-w /var/svs \
	--net inacademia.local \
	--ip 172.172.172.1 \
	--add-host=svs.inacademia.local:172.172.172.1 \
	--add-host=op.inacademia.local:172.172.172.2 \
	--add-host=rp.inacademia.local:172.172.172.100 \
	--add-host=idp.inacademia.local:172.172.172.200 \
	--hostname svs.inacademia.local \
	--expose 80 \
	--expose 443 \
	$IMAGE_TAG



