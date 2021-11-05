#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'


COMPOSE_FILES="docker-compose.yml"

function display_url_status(){
    HOST="$1"
    # shellcheck disable=SC1083
    HTTP_STATUS="$(curl -s -o /dev/null -L -w ''%{http_code}'' "${HOST}")"
    if [[ "${HTTP_STATUS}" != "200" ]] ; then
        echo "${HOST}  -> Down"
    else
        echo "${HOST}  -> Up"
    fi
}

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
  up)
    echo "Spinning up Docker Images..."
    echo "If this is your first time starting sandbox this might take a minute..."
    #eval docker-compose  "-f ${COMPOSE_FILES}" up -d --build
    eval docker-compose  "-f ${COMPOSE_FILES}"  run --rm start_dependencies
    ;;
  down)
    echo "Stopping sandbox containers..."
    eval docker-compose  "-f ${COMPOSE_FILES}" down -v  --remove-orphans
    docker container prune -f
    ;;
  status)
    echo "Querying sandbox containers status..."
    display_url_status "http://localhost:3000"
    display_url_status "http://localhost:8080"
    eval docker-compose "-f ${COMPOSE_FILES}"  ps
    ;;
  enter)
    eval docker-compose  "-f ${COMPOSE_FILES}" logs -f exec semaphore sh
    ;;
  logs)
    eval docker-compose  "-f ${COMPOSE_FILES}" logs -f 
    ;;
    *)
    cat <<-EOF
sandbox commands:
----------------
  up            -> spin up environment
  down          -> tear down environment
  status        -> displays status of  services
  enter         -> enter the app container
  logs          -> stream container logs  
EOF
    ;;
  esac
