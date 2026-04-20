# kill display manager (gdm) so new framvuffer can be made
sudo systemctl stop display-manager
# restart nomachine
sudo /etc/NX/nxserver --restart
# regenerate nvidia container setup to not expect a screen connected (framebuffer fb0)
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml --mode=csv
