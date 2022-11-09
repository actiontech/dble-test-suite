#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "==========安装容器=========="
docker-compose -f docker-compose.yml up -d --force
echo "==========容器部署成功=========="

echo "==========免密配置=========="
bash ${DIR}/docker-build-behave/ssh_config.sh
echo "==========免密配置完成=========="

echo "==========mysql实例部署=========="
bash ${DIR}/docker-build-behave/init_test_env.sh
echo "==========mysql实例部署完成=========="

