#!/bin/sh -eu

get_file_name() {
  file=${1##*/}
  echo "${file%.*}"
}

DPPM_REST_API_GIT=git@github.com:DFabric/dppm-rest-api.git
DPPM_WEBUI_GIT=git@github.com:DFabric/dppm-webui.git
: ${DPPM_REST_API_DIR=$PWD/$(get_file_name $DPPM_REST_API_GIT)}
: ${DPPM_BIN=$DPPM_REST_API_DIR/bin/dppm}
: ${DPPM_WEBUI_DIR=$PWD/$(get_file_name $DPPM_WEBUI_GIT)}

SCRIPTS_DIR=scripts
[ -d "$DPPM_REST_API_DIR" ] || git clone $DPPM_REST_API_GIT $DPPM_REST_API_DIR
[ -d "$DPPM_WEBUI_DIR" ] || git clone $DPPM_WEBUI_GIT $DPPM_WEBUI_DIR

print_env_vars() {
  printf "\nENV_VARS:\n"
  awk -F'{' '/^: \${/ { sub(/}$/, "", $2); print "  " $2 }' $1
}

script="$SCRIPTS_DIR/${1-}.sh"

if [ -f "$script" ]; then
  case ${2-} in
    -h|--help)
      printf "[ENV_VARS...] $0 $1\n"
      print_env_vars $script;;
    *) . $script;;
  esac
else

  cat <<HELP
[ENV_VARS...] $0 [COMMAND]

Run integration tasks

COMMAND:
HELP

  for script in $SCRIPTS_DIR/*; do
    echo "  $(get_file_name $script)"
  done

  print_env_vars $0
fi
