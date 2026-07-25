#!/bin/sh

set -eu

homebridge_dir="${HOMEBRIDGE_DIR:-/homebridge}"
project_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_dir=$(mktemp -d)

cleanup() {

  rm -rf "$package_dir"
}

trap cleanup EXIT HUP INT TERM

if [ ! -d "$homebridge_dir/node_modules" ]; then

  echo "Homebridge node_modules directory not found: $homebridge_dir/node_modules" >&2
  exit 1
fi

cd "$project_dir"
npm ci
npm run build

package_name=$(npm pack --silent --pack-destination "$package_dir")
package_path="$package_dir/$package_name"

npm install --prefix "$homebridge_dir" --omit=dev "$package_path"

installed_version=$(node -p "require('$homebridge_dir/node_modules/homebridge-unifi-access/package.json').version")
echo "Installed homebridge-unifi-access@$installed_version in $homebridge_dir/node_modules."
