tc-is_64bit() {
	[[ "${ARCH%64}" != "${ARCH}" ]]
}
