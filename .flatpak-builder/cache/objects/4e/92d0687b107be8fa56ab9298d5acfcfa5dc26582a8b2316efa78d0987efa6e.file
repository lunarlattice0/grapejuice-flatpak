title: Install Graphics Libraries
---
## About Graphics libraries

Playing Roblox Will result in a White or Black or an empty Skybox screen upon loading up, Or crash.

To fix this, The 32-bit graphics libraries are required for certain distributions.

**NOTE**: These commands will work if you have a [Vulkan capable GPU](https://en.wikipedia.org/wiki/Vulkan_(API)#Compatibility), Incase you don't, Proceed with removing what is related to Vulkan from the Commands.

## Installing Graphics libraries

### Arch / Manjaro / Other Arch Linux derivatives

#### Enabling 32-bit support

You enable 32-bit support by editing `/etc/pacman.conf` with your favourite editor, where you uncomment the multilib
repository. Note that you have to be root in order to edit the file. The resulting file should contain the following:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

##### NVIDIA

```sh
sudo pacman -S --needed lib32-nvidia-utils vulkan-icd-loader lib32-vulkan-icd-loader
```

##### AMD

```sh
sudo pacman -S --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
```

##### Intel
```sh
sudo pacman -S --needed lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
```

### Fedora
dnf will pull the required graphics driver required by your system already.

To install Vulkan support:

```sh
sudo dnf install vulkan-loader vulkan-loader.i686
```

### OpenSUSE

##### NVIDIA

The closed source NVIDIA driver is not available by default.

For Vulkan support on NVIDIA drivers Incase you manage to install them:

```sh
sudo zypper in libvulkan1 libvulkan1-32bit
```

##### AMD

```sh
sudo zypper in kernel-firmware-amdgpu libdrm_amdgpu1 libdrm_amdgpu1-32bit libdrm_radeon1 libdrm_radeon1-32bit libvulkan_radeon libvulkan_radeon-32bit libvulkan1 libvulkan1-32bit
```

##### Intel

```sh
sudo zypper in kernel-firmware-intel libdrm_intel1 libdrm_intel1-32bit libvulkan1 libvulkan1-32bit libvulkan_intel libvulkan_intel-32bit
```

### Void

#### Enabling 32-bit support

```sh
sudo xbps-install void-repo-multilib
```

##### NVIDIA

```sh
sudo xbps-install nvidia-libs-32bit vulkan-loader vulkan-loader-32bit
```

##### AMD

```sh
sudo xbps-install mesa-dri vulkan-loader vulkan-loader-32bit
```

##### Intel

```sh
sudo xbps-install mesa-dri mesa-vulkan-intel vulkan-loader vulkan-loader-32bit
```
