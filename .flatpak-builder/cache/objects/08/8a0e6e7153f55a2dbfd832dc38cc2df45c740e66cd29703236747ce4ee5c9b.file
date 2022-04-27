title: Performance Tweaks
---
This page describes some of the ways to improve performance and reduce input lag for Roblox or Roblox Studio.

**Table of Contents**

[TOC]

---

## Improving Roblox performance

### Using Wayland

Using Wayland with Xwayland can sometimes improve performance.

**NOTE**: Wayland is currently experimental.
Nvidia on Wayland is also quite unstable (This statement will change with time). If you have an GPU like Intel or AMD, You'd have to compile Wine with Wayland support.

### Change the renderer

You can change the renderer by opening the Grapejuice app, selecting `Player` on the left, and then modifying the `Roblox Renderer` under `Graphics Settings`. Generally, you can try each one of them and seeing which one works best. If Roblox happens to not launch after the logo shows up, you can enable `Use Mesa OpenGL version override`.

### Using DXVK

Instead of changing the renderer, you can also try DXVK.

First, open the Grapejuice App, select `Player` on the left, and then enable `Use DXVK D3D implementation`. You also need to set the Roblox renderer to `DX11`, as shown above.

## Improving Roblox Studio performance

Open Studio, then press Alt+S, and then go to the renderer tab. Options such as the quality level and graphics level are available.

You can also open the Grapejuice app, select studio on the left, and change the renderer.

Studio's Vulkan renderer requires the [child window renderer patch](https://github.com/Frogging-Family/wine-tkg-git/blob/master/wine-tkg-git/wine-tkg-patches/misc/childwindow.patch). It should be included if you're already using Wine TKG. Note that the pre-built patched Wine provided on the documentation does not have the childwindow patch.

## Performance on laptops that use nVIDIA PRIME

**this section is a work-in-progress**

People with a laptop, specifically one which uses nVIDIA Optimus technology (hybrid graphics: Intel iGPU + nVIDIA dGPU, etc...), might find they still get bad performance, no matter what they do.

This is because Roblox is using the integrated graphics card instead of the dedicated one.

The solution is to select the nVIDIA GPU as your primary one. It may also work to use hybrid mode and select the dedicated GPU from inside Grapejuice. 

Due to the fast-changing and distro-dependent nature of nVIDIA PRIME configuration, we cannot document it here in-depth.

**⚠️ IMPORTANT NOTICE**: Please take caution when following the guide below. Some people reported broken Linux installs after doing similar steps. Back up your data first and report any issues with this guide. It is yet to be fully tested due to the nature of nVIDIA PRIME.

**For Pop!_OS**: You should be able to click on the top-right menu on the top bar and select the GPU on the power dropdown.

**For Ubuntu or Ubuntu-based distros (!!NOT POP!_OS)**: You should be able to install the proprietary drivers and change the primary GPU by going to the nVIDIA X Server settings and selecting `PRIME Profiles` on the left. For some versions, the `nvidia-prime` package may also be needed.

**For Arch Linux**: [optimus-manager](https://github.com/Askannz/optimus-manager) may work.

More info may be found [on the Arch Wiki page](https://wiki.archlinux.org/title/NVIDIA_Optimus)
