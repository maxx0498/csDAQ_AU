# csDAQ
*NC State Cold-Stage Data Acquisition System*

The repository contains software to operate the cold stage data acquisition system. 

## Standard Linux Install

We recommend using the containerized install described here [https://github.com/CIF-Cold-Stage/deploy-cif](https://github.com/CIF-Cold-Stage/deploy-cif). This method is mostly automated and pulls all dependencies.

The ```Containerfile``` in the deploy-cif repository reproduced below contains the steps that can be reproduced on real hardware. 

```docker
# Use Ubunutu 22.04 Image. Ubuntu is supported for IDS Peak
FROM docker.io/library/ubuntu:22.04

LABEL summary="Deploy container for CIF Cold Stage" \
      maintainer="Markus Petters <mdpetter@ncsu.edu>"

# Install package dependencies for IDS Peak and csDAQ
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install libqt5core5a libqt5gui5 libqt5widgets5 libqt5multimedia5 libqt5quick5 qml-module-qtquick-window2 qml-module-qtquick2 qtbase5-dev qtdeclarative5-dev qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qtquick-layouts qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel libusb-1.0-0 libatomic1 git wget gpg python3 python3-pip apt-transport-https vim

# Download and install julia version
ENV JULIA_VERSION=1.8.5

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Install VS Code 
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
RUN rm -f packages.microsoft.gpg
RUN apt-get update && \
    apt-get -y install code

# Install IDS Peak drivers
# This pulls the deb package from a google drive link and installs it
# dpkg will install the udev rules. However, the rules.d directory doesn't exist in a container
RUN pip install gdown && \
    gdown https://drive.google.com/uc?id=11BJlKy6Jp5HTbDq9Nqw445gDX4AZumbZ && \
    mkdir /etc/udev && \
    mkdir /etc/udev/rules.d && \
    dpkg -i ids-peak-linux-x86-2.1.0.0-64.deb

RUN pip install "/usr/local/share/ids/bindings/python/wheel/ids_peak_ipl-1.4.0.0-cp310-cp310-linux_x86_64.whl" && \
    pip install "/usr/local/share/ids/bindings/python/wheel/ids_peak-1.4.2.2-cp310-cp310-linux_x86_64.whl"

# Install DropFreezingDetection and csDAQ software in /opt folder of container
RUN cd /opt && \
    git clone https://github.com/CIF-Cold-Stage/csDAQ.git && \
    git clone https://github.com/CIF-Cold-Stage/DropFreezingDetection.jl

# Fix Permissions so $USER can access it from distrobox
RUN chmod -R a+rw /opt

RUN touch /etc/localtime
```

## General Steps

1. Provision the OS. Linux Ubuntu-22.04 is preferred for full compatibility.
2. Install the dependencies
3. Install VS-Code editor
4. Install Julia. The latest version from [https://julialang.org/downloads/](https://julialang.org/downloads/) should work. 
5. Install IDS Peak. You will need to download the latest version from [https://www.ids-imaging.us/](https://www.ids-imaging.us/).
6. Test that the camera works using IDS Cockpit
7. Test that the python bindings work to control the camera
8. Identify the serial port and test that communication with temperature controller works [https://github.com/CIF-Cold-Stage/TETechTC3625RS232.jl](https://github.com/CIF-Cold-Stage/TETechTC3625RS232.jl)
9. Run the csDAQ ```main.jl```. For initial install, it is recommended to execute the code line-by-line from VS-Code to catch potential errors.

### Porting to Windows or MacOS

We have managed to run this code on MS Windows without issues. However, the code may need slight tweaking, depending on the selected environment. 