#/bin/bash

cd /opt/DropFreezingDetection.jl/src   
julia --project -e "using Pkg; Pkg.instantiate(); Pkg.precompile();"
cd /opt/csDAQ/src   
julia --project -e "using Pkg; Pkg.instantiate(); Pkg.precompile();"


cd $HOME
cat << EOF | tee 50-usb-serial.rules
SUBSYSTEM=="tty", SUBSYSTEMS=="usb-serial", OWNER="${USER}"
EOF

cp /etc/udev/rules.d/99-ids-usb-access.rules . 