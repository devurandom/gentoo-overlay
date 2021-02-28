#!/bin/bash

set -u
set -e

# "Good style" would be to use "dependency" to get the version bundled with
# Maven, but then (as of Maven 3.6.0) we would get an old version with bugs
# and missing features.  Thus force version 3.1.2 for now.
mvn_dependency_plugin=org.apache.maven.plugins:maven-dependency-plugin:3.1.2

mvn_home="$(mktemp -d)"

onexit() {
	rm -fr "${mvn_home}"
}
trap onexit EXIT

# `-Dsilent=true` has no effect, so we do not even try.  Instead we redirect
# stdout to /dev/null and redirect the output we actually want to stdout
# using `>(cat)`.
# `-Dsort=true` has no effect, so we do not even try.  Please sort (and unify)
# the output of this script yourself.
mvn \
	-DincludeParents=true \
	-Duser.home="${mvn_home}" \
	"${mvn_dependency_plugin}":resolve \
	"${mvn_dependency_plugin}":resolve-plugins > /dev/null

# The list Maven gives us is not complete (it is missing a bunch of
# high-level POMs), hence we list the POMs and JARs it downloaded to
# its repository cache.

mvn_repository="${mvn_home}/.m2/repository/"

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

find "${mvn_repository}" -name '*.jar' -o -name '*.pom' | while read file ; do
	parse_filename "${file}"
done | sort -u
