#!/bin/sh -eu

keep_data_dir=true
[ "${DATA_DIR:-}" ] || keep_data_dir=false
: ${DPPM_USER=user}
: ${SHARDS_BIN=shards}
: ${GROUP_ID=1000}
# By default don't create an admin user
: ${ADMIN=false}
: ${DATA_DIR=$(mktemp -d --suffix=_dppm_data)}

# Remove temporary data dir at error/exit
trap '${keep_data_dir} || rm -rf "$DATA_DIR"' EXIT INT QUIT TERM ABRT

echo "DATA_DIR: $DATA_DIR"
echo '{"groups":[], "users": []}' > $DATA_DIR/permissions.json

[ -d "$DPPM_REST_API_DIR" ] || git clone $DPPM_REST_API_GIT $DPPM_REST_API_DIR
cd $DPPM_REST_API_DIR

$SHARDS_BIN build
$DPPM_BIN server group add data_dir=$DATA_DIR name="${DPPM_USER}'s group" id=$GROUP_ID
$DPPM_BIN server user add data_dir=$DATA_DIR name="$DPPM_USER" groups=$GROUP_ID

if $ADMIN; then
  $DPPM_BIN server group add data_dir=$DATA_DIR name="admin's group" id=0 permissions='
      {
        "/**": {
          "permissions": [
            "Create", "Read", "Update", "Delete"
          ],
          "query_parameters": { }
        }
      }'
  $DPPM_BIN server data_dir=$DATA_DIR user add name=admin groups=0
fi

$DPPM_BIN server run data_dir=$DATA_DIR
