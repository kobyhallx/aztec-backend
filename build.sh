#!/usr/bin/env bash

main_dir=$(pwd)
GIT_VENDOR_URL="https://github.com"
NOIR_REPO_PATH="noir-lang/noir"
AZBACKEND_REPO_PATH="kobyhallx/aztec_backend"

CACHE_DIR="$main_dir/.cache"
BUILD_ROOT_DIR="$main_dir/.build"

NOIR_REPO_CACHE="$CACHE_DIR/noir"
NOIR_BUILD="$BUILD_ROOT_DIR/noir"
NOIR_CLONE_URL="$GIT_VENDOR_URL/$NOIR_REPO_PATH"

AZBACKEND_REPO_CACHE="$CACHE_DIR/aztec_backend"
AZBACKEND_BUILD="$BUILD_ROOT_DIR/aztec-backend"
AZBACKEND_CLONE_URL="$GIT_VENDOR_URL/$AZBACKEND_REPO_PATH"

rm -rf "$AZBACKEND_BUILD"

mkdir -p "$AZBACKEND_BUILD"

if [[ -d "$NOIR_REPO_CACHE" ]]; then
    echo "$NOIR_REPO_CACHE exists on your filesystem, using it for build..."
else
    echo "$NOIR_REPO_CACHE does not exists on your filesystem, clonning from $NOIR_CLONE_URL"
    git clone $NOIR_CLONE_URL $NOIR_REPO_CACHE
fi

AZTEC_BACKEND_REV=$(toml2json $NOIR_REPO_CACHE/crates/nargo/Cargo.toml | jq -r .dependencies.aztec_backend.rev)

if [[ -d "$AZBACKEND_REPO_CACHE" ]]; then
    echo "$AZBACKEND_REPO_CACHE exists on your filesystem, using it for build..."
else
    echo "$AZBACKEND_REPO_CACHE does not exists on your filesystem, clonning from $AZBACKEND_CLONE_URL"
    git clone $AZBACKEND_CLONE_URL $AZBACKEND_REPO_CACHE
    cd $AZBACKEND_REPO_CACHE
    git reset --hard $AZTEC_BACKEND_REV
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

rm $AZBACKEND_BUILD/aztec_backend_wasm/pkg/nodejs/package.json $AZBACKEND_BUILD/aztec_backend_wasm/pkg/nodejs/README.md $AZBACKEND_BUILD/aztec_backend_wasm/pkg/nodejs/.gitignore
rm $AZBACKEND_BUILD/aztec_backend_wasm/pkg/web/package.json $AZBACKEND_BUILD/aztec_backend_wasm/pkg/web/README.md $AZBACKEND_BUILD/aztec_backend_wasm/pkg/web/.gitignore


cd $main_dir

rm -rf $main_dir/nodejs
rm -rf $main_dir/web
rm $main_dir/package.json

cp -a "$AZBACKEND_BUILD/aztec_backend_wasm/pkg/nodejs/." ./nodejs
cp -a "$AZBACKEND_BUILD/aztec_backend_wasm/pkg/web/." ./web
cp "$AZBACKEND_BUILD/aztec_backend_wasm/pkg/package.json" $main_dir/

cd $AZBACKEND_BUILD
AZBACKEND_REV=$(git rev-parse HEAD)
AZBACKEND_REV_SHORT=$(git rev-parse --short HEAD)

cd $main_dir
sed -i -E "s/\[noir-lang\/noir@.+\]\(.+\)/\[noir-lang\/noir@$AZBACKEND_REV_SHORT\](https:\/\/github.com\/noir-lang\/noir\/tree\/$AZBACKEND_REV)/g" $main_dir/README.md

cat $main_dir/package.json | jq '.name = "@noir-lang/aztec_backend"' | jq '.repository = { "type" : "git", "url" : "https://github.com/noir-lang/aztec-backend.git" }' | tee ./package.json


