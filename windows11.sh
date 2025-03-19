#!/bin/bash

echo -e '\033[1;37mInstalling QEMU and dependencies...\033[0m'
sudo apt-get update
sudo apt-get install -y qemu-system-x86 qemu-utils p7zip-full wget curl

echo -e '\033[1;37mCreating VM directory...\033[0m'
mkdir -p ~/VM
cd ~/VM

echo -e '\033[1;37mDownloading OVMF firmware...\033[0m'
wget https://github.com/AnBui2004/termux/raw/refs/heads/main/OVMF.fd

echo -e '\033[1;37mDownloading Windows 11 image...\033[0m'
wget -O windows11.7z https://archive.org/download/windows-11.7z_202410/Windows%2011.7z
7z x windows11.7z
rm windows11.7z

echo -e '\033[1;37mCreating startup script...\033[0m'
cat > ~/start_win11.sh << 'EOL'
#!/bin/bash
cd ~/VM
qemu-system-x86_64 \
  -M q35 \
  -usb -device usb-tablet -device usb-kbd \
  -cpu max \
  -smp cores=2,threads=2 \
  -m 2048M \
  -drive file=W11.qcow2,if=virtio \
  -vga virtio \
  -device virtio-net-pci,netdev=n0 \
  -netdev user,id=n0 \
  -accel tcg,thread=multi \
  -bios OVMF.fd \
  -device virtio-balloon-pci \
  -device virtio-rng-pci \
  -display vnc=:0
EOL

chmod +x ~/start_win11.sh

echo -e '\033[1;37mInstalling noVNC for web access...\033[0m'
git clone https://github.com/novnc/noVNC.git ~/noVNC
cd ~/noVNC
git checkout v1.4.0
cd ~/

cat > ~/start_novnc.sh << 'EOL'
#!/bin/bash
cd ~/noVNC
./utils/novnc_proxy --vnc localhost:5900 --listen localhost:8080
EOL

chmod +x ~/start_novnc.sh

cat > ~/run_vm.sh << 'EOL'
#!/bin/bash
echo "Starting Windows 11 VM..."
~/start_win11.sh &
sleep 5
echo "Starting noVNC web server..."
~/start_novnc.sh &
sleep 2
echo "VM is running!"
echo "Access your VM through Web Preview on port 8080"
echo "To stop the VM, use: pkill qemu"
EOL

chmod +x ~/run_vm.sh

echo -e '\033[1;37mDone!\033[0m'
echo -e '\033[1;37mUse this command to start the VM: ./run_vm.sh\033[0m'
echo -e '\033[1;37mThen use Web Preview (port 8080) in Cloud Shell to access the VM\033[0m'
echo -e '\033[1;37m----------\033[0m'
echo -e '\033[1;37mThe necessary files are in the VM folder. Please do not delete these files.\033[0m'
