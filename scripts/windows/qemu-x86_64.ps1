# save current directory
$pwd = ${pwd}

# go to qemu folder
cd 'C:/Program Files/qemu'

# run with qemu
qemu-system-x86_64 -cdrom "${pwd}/dist/x86_64/kernel.iso"

# return
cd $pwd