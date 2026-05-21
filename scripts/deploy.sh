#!/usr/bin/env bash

DEPLOY_ROOT="${DEPLOY_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}"

echo ">>> 배포 스크립트를 실행합니다."

# blue, green 인자로 받음
TARGET=$1

if [ "$TARGET" != "blue" ] && [ "$TARGET" != "green" ]; then
    echo "오류: 'blue' 또는 'green'을 입력해주세요. (예: ./deploy.sh [blue or green])"
        exit 1
fi


DIR_PATH="${DEPLOY_ROOT}/${TARGET}-server"


echo ">>> ${TARGET}서버 배포를 시작합니다."
#cd $DIR_PATH || exit

echo ">>> docker compose 실행중 "
docker compose -f "${DIR_PATH}/docker-compose-${TARGET}-infra.yml" up -d || { echo "❌ 인프라 도커 실행 실패!"; exit 1; }
docker compose -f "${DIR_PATH}/docker-compose-${TARGET}.yml" up -d || { echo "❌ 서버 도커 실행 실패!"; exit 1; }


echo ">>> ${TARGET}서버 실행 완료! "





