#!/usr/bin/env bash

main_dir=$(pwd)
CACHE_DIR="$main_dir/.cache"
AZBACKEND_REPO_CACHE="$CACHE_DIR/aztec-backend"
GIT_VENDOR_URL="https://github.com"
AZBACKEND_REPO_PATH="kobyhallx/aztec-backend"
AZBACKEND_CLONE_URL="$GIT_VENDOR_URL/$AZBACKEND_REPO_PATH.git"
AZBACKEND_BUILD="$main_dir/.build"

rm -rf "$AZBACKEND_BUILD"

mkdir -p "$AZBACKEND_BUILD"

if [[ -d "$AZBACKEND_REPO_CACHE" ]]; then
    echo "$AZBACKEND_REPO_CACHE exists on your filesystem, using it for build..."
else
    echo "$AZBACKEND_REPO_CACHE does not exists on your filesystem, clonning from $AZBACKEND_CLONE_URL"
    git clone $AZBACKEND_CLONE_URL $AZBACKEND_REPO_CACHE
    cd $AZBACKEND_REPO_CACHE
    git checkout f96d5baed03d5058e783827d105e2c83d290c65d
fi

cp -a "$AZBACKEND_REPO_CACHE/." "$AZBACKEND_BUILD/"

cd "$AZBACKEND_BUILD/aztec_backend_wasm"

wasm-pack build --scope noir-lang --target nodejs --out-dir pkg/nodejs

wasm-pack build --scope noir-lang --target web --out-dir pkg/web

COMMIT_SHORT=$(git rev-parse --short HEAD)
VERSION_APPENDIX=""
if [ -n "$COMMIT_SHORT" ]; then
    VERSION_APPENDIX="-$COMMIT_SHORT"
else
    VERSION_APPENDIX="-NOGIT"
fi

jq -s '.[0] * .[1]' pkg/nodejs/package.json pkg/web/package.json | jq '.files = ["nodejs", "web", "package.json"]' | jq ".version += \"-$(git rev-parse --short HEAD)\"" | jq '.main = "./nodejs/" + .main | .module = "./web/" + .module | .types = "./web/" + .types' | tee ./pkg/package.json

rm pkg/nodejs/package.json pkg/nodejs/README.md pkg/nodejs/.gitignore
rm pkg/web/package.json pkg/web/README.md pkg/web/.gitignore


cd $main_dir

rm -rf ./nodejs
rm -rf ./web
rm package.json

cp -a "$AZBACKEND_BUILD/aztec_backend_wasm/pkg/nodejs/." ./nodejs
cp -a "$AZBACKEND_BUILD/aztec_backend_wasm/pkg/web/." ./web
cp "$AZBACKEND_BUILD/aztec_backend_wasm/pkg/package.json" ./

cd $AZBACKEND_BUILD
AZBACKEND_REV=$(git rev-parse HEAD)
AZBACKEND_REV_SHORT=$(git rev-parse --short HEAD)

cd $main_dir
sed -i -E "s/\[noir-lang\/noir@.+\]\(.+\)/\[noir-lang\/noir@$AZBACKEND_REV_SHORT\](https:\/\/github.com\/noir-lang\/noir\/tree\/$AZBACKEND_REV)/g" ./README.md

cat ./package.json | jq '.name = "@noir-lang/aztec_backend"' | jq '.repository = { "type" : "git", "url" : "https://github.com/noir-lang/aztec-backend.git" }' | tee ./package.json


