#!/bin/bash

set -e

lockfile="$1"
[[ "${lockfile}" ]] || exit 1

sed -nr '/^"checksum/s/"checksum\s+(\S+)\s+(\S+).*/\1-\2/p' "${lockfile}" | sort -u
