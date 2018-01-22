PWD=$(shell pwd)
BINARY=server
NAME=mobile-api-go

BUILD_TIME=`date -u '+%Y-%m-%dT%T%Z'`
BUILD_GIT_HASH=`git rev-parse HEAD`
BUILD_GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
BUILD_GIT_STATE=`git diff --quiet --exit-code && echo 'clean' || echo 'dirty'`
BUILD_VERSION=`cat VERSION`
BUILD_AUTHOR_EMAIL=`git config user.email`

GOPAHT_PATH=GOPATH=${PWD}/vendor:${PWD}/tests/vendor:${PWD}
GOLANG_ENV=CGO_ENABLED=0 GOOS=linux GOARCH=amd64
BUILD_FLAGS=-X configuration.buildtime=${BUILD_TIME} -X configuration.buildgithash=${BUILD_GIT_HASH} -X configuration.buildbranch=${BUILD_GIT_BRANCH} -X configuration.buildgitstate=${BUILD_GIT_STATE} -X configuration.version=${BUILD_VERSION} -X configuration.buildauthoremail=${BUILD_AUTHOR_EMAIL}
FLAGS=-installsuffix cgo -ldflags "-w -extld ld -extldflags -static ${BUILD_FLAGS}" -a
GET_GB=go get github.com/constabulary/gb/...

TESTS_SQLDUMP?=${PWD}/tests/src/babo.sql
TESTS_PG_HOST?=localhost
TESTS_EXTERNAL_PG?=no
TESTS_REDIS_HOST?=localhost
TESTS_REDIS_PORT?=6379
TESTS_EXTERNAL_REDIS?=no

DOCKER_BASE_IMAGE=alpine3.3
REGISTRY_HOST?=registry.life-team.net

VERSION ?= $(shell cat VERSION)-$(DOCKER_BASE_IMAGE)-$(shell git rev-parse --short HEAD)

IMAGE=${REGISTRY_HOST}/babo/${NAME}:${VERSION}

run: build
	bin/${BINARY}

static: check_vendor clean
	${GOPAHT_PATH} ${GOLANG_ENV} go build ${FLAGS} -o bin/${BINARY} ${BINARY}

tests: check_tests_vendor check_vendor clean
	${GOPAHT_PATH} SERVER_ENV=test  go test -tags tests ./src/... -args --sqldump ${TESTS_SQLDUMP} --use-external-postgres ${TESTS_EXTERNAL_PG} --postgres-host ${TESTS_PG_HOST} --use-external-redis ${TESTS_EXTERNAL_REDIS} --redis-host ${TESTS_REDIS_HOST} --redis-port ${TESTS_REDIS_PORT}

build: check_vendor clean
	gb build -ldflags "$(BUILD_FLAGS)" server

docker:
	docker build -t ${IMAGE} .

docker_latest:
	VERSION=latest make docker

push: docker
	docker push ${IMAGE}

push_latest:
	VERSION=latest make push

check_vendor: check_gb_tool
	if [ ! -d "vendor/src" ]; then gb vendor restore; fi

check_tests_vendor: check_gb_tool
	if [ ! -d "tests/vendor/src" ]; then cd tests && gb vendor restore; fi

check_gb_tool:
	if ! which gb > /dev/null; then echo "Need install gb. Run: go get github.com/constabulary/gb/..."; exit 1; fi

deploy:
	sed -i -E -e "s~image:\s.+~image: $(IMAGE)~g" k8s/${DEPLOY_CONF_FILE} && kubectl apply -f k8s/${DEPLOY_CONF_FILE}

show_name:
	@echo ${IMAGE}


# Cleans our project: deletes binaries
clean:
	rm -f bin/*
