To start noctalia-shell, you have two options:

1. Run directly:
   qs -c noctalia-shell

2. Set up as a runit user service:
   mkdir -p ~/service
   ln -s /usr/share/noctalia-shell/sv ~/service/noctalia-shell

The service will start immediately once linked to ~/service/.

Note: Make sure you have runsvdir running for your user services.
Check if it's active with: sv status runsvdir-$USER
