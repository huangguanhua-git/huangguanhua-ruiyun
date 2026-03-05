ISO_MNT=/mnt/custom-os/X86_64/iso-ubuntu
CASPER=${ISO_MNT}/casper

SIZE=$(unsquashfs -s "${CASPER}/ubuntu-server-minimal.ubuntu-server.squashfs" \
	       | awk '/^Filesystem size/{print $3}')
echo "${SIZE}" | sudo tee "${CASPER}/ubuntu-server-minimal.ubuntu-server.size" >/dev/null

dpkg-query -W --showformat='${Package} ${Version}\n' > "${CASPER}/ubuntu-server-minimal.ubuntu-server.manifest"
