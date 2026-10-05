#!/bin/bash
# Description: Update copyright year in the index.html file.
# shellcheck disable=SC2155

set -o errexit -o nounset -o pipefail

# This script includes Git operations.
if [[ $EUID == 0 ]]; then
    echo "This script must not be run as root" >&2
    exit 1
fi

declare -ir new_year=$(date +%Y)
declare -ir old_year=$((new_year - 1))

declare -r workspace="$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")"
builtin cd "${workspace}"

if ! git diff --staged --quiet; then
    echo "There are staged changes. Please commit or stash them first." >&2
    exit 1
fi

declare -r target_file=index.html

# Replace all occurrences of "2026" in files with "2027", for example.
sed -e "s/$old_year/$new_year/g" -i "$target_file"
if git diff --quiet "$target_file"; then
    echo "No changes." >&2
    exit 0
fi

git add -u "$target_file"
git commit -m "index.html: s/$old_year/$new_year/"
git push origin master
