# about 3.5 GB for download
# and 7.5 GB for osmosis filter
needed=14000
avail=`df / --output=avail --block-size=M |grep -v Avail |sed -e '1,$s/M//'`
echo "INFO  Available: $avail MB"
echo "INFO  Needed: about $needed MB"

if (( $avail > $needed )); then
  echo "INFO  Ok :-)"
else
  echo "ERROR Not enough disk space!"
  echo "INFO  1. Windows-Hypervisor: VBoxManage modifyhd h:\VirtualBoxVMs\Test\Test-disk1.vdi --resize 23000"
  echo "INFO  2. Linux: sudo gparted"
fi
