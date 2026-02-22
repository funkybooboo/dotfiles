# Set default libvirt connection to system (not session)
# This ensures virt-manager and virsh use qemu:///system by default
export LIBVIRT_DEFAULT_URI="qemu:///system"
