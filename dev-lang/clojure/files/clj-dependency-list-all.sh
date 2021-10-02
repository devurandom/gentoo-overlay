#!/bin/bash

set -u
set -e

mvn_home="$(mktemp -d)"
mvn_repository="${mvn_home}/.m2/repository/"

onexit() {
	rm -fr "${mvn_home}"
}
trap onexit EXIT

parse_filename() {
	local absolute_path="$1"

	relative_path="${absolute_path##${mvn_repository}}"
	extension="${absolute_path##*.}"

	dir="$(dirname "${relative_path}")"
	version="$(basename "${dir}")"

	dir="$(dirname "${dir}")"
	artifact_id="$(basename "${dir}")"

	dir="$(dirname "${dir}")"
	group_id="$(echo "${dir}" | tr / .)"

	filename="$(basename "${relative_path}")"
	if [[ "${filename}" != "${artifact_id}-${version}.${extension}" ]] ; then
		# It contains an additional classifier (used for a few JARs)
		classifier="${filename}"
		classifier="${classifier##${artifact_id}-${version}-}"
		classifier="${classifier%%.${extension}}"
		echo "${group_id}:${artifact_id}:${extension}:${classifier}:${version}"
	else
		echo "${group_id}:${artifact_id}:${extension}:${version}"
	fi
}

clojure -J-Duser.home="${mvn_home}" -X:build release > /dev/null

find "${mvn_repository}" -name '*.jar' -o -name '*.pom' | while read file ; do
	parse_filename "${file}"
done | sort -u
