Write-Host 'Checking for VirtualBox.....' -NoNewline
if (Get-Command VBoxManage.exe) {
  Write-Host 'VirtualBox(VBoxManage.exe).....[' -NoNewline
  Write-Host 'Found' -ForegroundColor Green -NoNewline
  Write-Host ']....Continuing.'
} else {
  Write-Host 'VirtualBox(VBoxManage.exe).....[' -NoNewline
  Write-Host 'Not Found' -ForegroundColor Green -NoNewline
  Write-Host ']....Exiting.'
  Write-Host 'Installing VirtualBox from virtualbox.org is ' -ForegroundColor Yellow -NoNewline
  Write-Host 'Required' -ForegroundColor Red
  Exit-PSHostProcess
}

if ( $Env:VM) {
  $VM = $Env:VM
  Write-Host "Using VM Name: $Env:VM." -ForegroundColor Green
} else {
  $VM = 'ksu-auv-dev'
  Write-Host "Using default VM name: 'ksu-auv-dev'" -ForegroundColor Green
}


if ($Env:VM_PATH) {
  $path = $Env:VM_PATH
  Write-Host "Using $Env:VM_PATH for VM storage." -ForegroundColor Green
} else {
  if ([System.IO.File]::Exists('$HOME\VirtualBox VMs')) {
    $path = '$HOME\VirtualBox VMs'
    Write-Host "Using VirtualBox Default storage path: $HOME/'VirtualBox VMs'" -ForegroundColor Green
  } else {
    Write-Host "Couldn't determine where to store VM. Exiting. Please define $Env:VM_PATH" -ForegroundColor Red
    Exit-PSHostProcess
  }
}

$stored_pwd = $PWD
Push-Location $path
if ([System.IO.File]::Exists($path+'/ubuntu-16.04.5-server-amd64.iso')) {
  Write-Host 'Seems you already have Ubuntu 16.04.5 Server (amd64).......' -NoNewline
  Write-Host 'Skipping Download' -ForegroundColor Green
} else {
  Write-Host 'Downloading Ubuntu 16.04.5 Server (amd64) to ' -NoNewline
  Write-Host $PWD -NoNewline
  Write-Host '.....' -NoNewline
  Invoke-WebRequest -Uri http://releases.ubuntu.com/xenial/ubuntu-16.04.5-server-amd64.iso -OutFile ubuntu-16.04.5-server-amd64.iso -UseBasicParsing
  Write-Host 'Done.' -ForegroundColor Green
}
Write-Host 'Creating and Registering VM......' -NoNewline
VBoxManage.exe createvm --name $VM --ostype "Ubuntu_64" --register
VBoxManage.exe createhd --filename $path\$VM\$VM.vdi --size 10240
Write-Host 'Done.' -ForegroundColor Green
Write-Host 'Configuring VM......' -NoNewline
VBoxManage.exe storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage.exe storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $path\$VM\$VM.vdi
VBoxManage.exe storagectl $VM --name "IDE Controller" --add ide
VBoxManage.exe storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $path\ubuntu-16.04.5-server-amd64.iso
VBoxManage.exe modifyvm $VM --ioapic on
VBoxManage.exe modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage.exe modifyvm $VM --memory 4096 --vram 256
VBoxManage.exe modifyvm $VM --uart1 0x3F8 4
VBoxManage.exe modifyvm $VM --uartmode1 tcpserver 23
VBoxManage.exe modifyvm $VM --natpf1 "guestssh,tcp,,2222,,22"
Write-Host 'Done.' -ForegroundColor Green
Write-Host 'Configuring for Unattended Install and Starting VM.....' -NoNewline
VBoxManage.exe unattended install $VM --iso=$path\ubuntu-16.04.5-server-amd64.iso --user=auv-dev --full-user-name=auv-dev --password=owlsub --time-zone=EST --script-template=$stored_pwd\ubuntu_preseed.cfg --extra-install-kernel-parameters='vga=normal console=ttyS0,115200n8 console=tty0 auto=true preseed/file=/cdrom/preseed.cfg priority=critical noprompt automatic-ubiquity debian-installer/locale=en_US keyboard-configuration/layoutcode=us languagechooser/language-name=English localechooser/supported-locales=en_US.UTF-8 countrychooser/shortlist=US'
VBoxManage.exe startvm $VM --type=headless
Write-Host 'Done.' -ForegroundColor Green
Write-Host 'VM is starting and will install ubuntu automatically.'
Write-Host 'U/P are: ' -NoNewline
Write-Host 'auv_dev/owlsub' -ForegroundColor Yellow
Write-Host 'Port Forwarding enabled, ssh from host to VM at: ' -NoNewline -ForegroundColor Green
Write-Host 'localhost:2222' -ForegroundColor Yellow
Push-Location $stored_pwd