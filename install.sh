distver=0.0.2
distdate=12.05.2019
kernver=4.20.12
echo
echo "PaxMax Winsux Installer 0.0.1"
echo "Lukas Flügel - 12.05.2019"
echo
echo "A Partition has to be present on your drive!"
echo "To create a partition before installation enter Ctrl+C"
echo "then type /root/install.sh to resume installation!"
echo "Please enter the partition block device path:"
while true; do
	read disk
	if [ ! -b "$disk" ]; then
		echo "This isn't a block device:"
		continue
	fi
	grubpart=$(echo ${disk:${#disk}-2:1} | tr '[a-j]' '[0-9]')
	grubpart="(hd$grubpart,${disk:${#disk}-1:1})"
	break
done

echo "Formatting the partition ..."
mkfs -t ext4 $disk
echo "Copying files ..."
mount -t ext4 $disk /mnt/winsux
cp -Rpv /bin /mnt/winsux/
mkdir /mnt/winsux/dev
mknod -m 600 /mnt/winsux/dev/console c 5 1
mknod -m 666 /mnt/winsux/dev/null c 1 3
cp -Rpv /etc /mnt/winsux/
mkdir /mnt/winsux/home
cp -Rpv /lib /mnt/winsux/
mkdir /mnt/winsux/media
mkdir /mnt/winsux/media/cdrom
mkdir /mnt/winsux/media/floppy
mkdir /mnt/winsux/mnt
mkdir /mnt/winsux/opt
mkdir /mnt/winsux/proc
mkdir /mnt/winsux/root
mkdir /mnt/winsux/run
cp -Rpv /sbin /mnt/winsux/
mkdir /mnt/winsux/srv
mkdir /mnt/winsux/sys
mkdir /mnt/winsux/tmp
chmod a+wt /mnt/winsux/tmp
cp -Rpv /usr /mnt/winsux/
cp -Rpv /var /mnt/winsux/
cat > /mnt/winsux/etc/issue <<< "Winsux Version $distver - Linux Kernel $kernver
$distdate
Made by Lukas Flügel, Raffael Sheikh, Filipe Bergdolt and Paul Hendriks
Made with LFS 8.4: http://www.linuxfromscratch.org/lfs/
and LFS Hints: http://www.linuxfromscratch.org/hints/
and BLFS 8.4: http://www.linuxfromscratch.org/blfs/"
echo "Unpacking files ..."
tar -xvf /root/winsux.tar.xz -C /mnt

echo "Making the partition bootable ..."
cat > /mnt/winsux/etc/fstab <<< "# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

$disk     /            ext4    defaults            1     1

# End /etc/fstab"
mkdir /mnt/winsux/boot
cp -pv /isolinux/vmlinuz /mnt/winsux/boot/vmlinuz-$kernver-winsux-$distver
cp -pv /isolinux/System.map-$kernver /mnt/winsux/boot/System.map-$kernver
cp -pv /isolinux/config-$kernver /mnt/winsux/boot/config-$kernver
grub-install ${disk:0:${#disk}-1} --root /mnt/winsux
cat > /mnt/winsux/boot/grub/grub.cfg <<< "# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod normal
set root=$grubpart

menuentry \"Winsux Version $distver - Linux Kernel $kernver\" {
        linux   /boot/vmlinuz-$kernver-winsux-$distver root=$disk video=1024x768 ro
}"

echo "Done!"
reboot

