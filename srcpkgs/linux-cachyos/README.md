# Post installation
`sudo xbps-reconfigure -f linux-cachyos`

`sudo dracut --force --hostonly /boot/initramfs-6.17.7-cachyos.img 6.17.7-cachyos` <- needs to match version

`sudo grub-mkconfig -o /boot/grub/grub.cfg` <- or however you update entries 
