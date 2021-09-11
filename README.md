# notion-repackaged

Notion Repackaged is an effort to bring the Notion app to all major Linux distributions as well as providing a variant with [notion-enhancer](https://github.com/notion-enhancer/notion-enhancer) embedded for both Windows, Linux and MacOS.

> This project is heavily inspired on [notion-linux](https://github.com/davidbailey00/notion-linux) and [AUR notion-app-enhanced](https://aur.archlinux.org/packages/notion-app-enhanced/) but extending on the idea of embedding notion-enhancer, providing an easy way to use notion-enhancer on all operating systems.

## Installation

> :warning: Make sure you don't run the official (or vanilla) and enhanced versions at the same time. You should only install one or the other. You can't just have your cake and eat it too.

Downloads are available at the repository releases section. 
You can go directly to [the latest release](https://github.com/notion-enhancer/notion-repackaged/releases/latest) and download the build for the platform you are using.

### Windows

Download the `exe` file from the release and install it, should be a pretty straightforward experience.

You can also download the `zip` build for Windows which provides a portable way to run the application.

### Linux

For linux there are two variants, `vanilla` and `enhanced`. The vanilla is a direct port of the official sources and the enhanced includes `notion-enhancer`.

Currently, we target the following package types:
- AppImage (any distribution, not actively tested)
- deb (Debian, Ubuntu, Pop!_OS, Linux Mint)
- rpm (Fedora)
- pacman (Arch Linux, Manjaro)
- zip (any, portable)

#### AppImage

AppImages are binary installers that are compatible with any Linux distribution, to install them you can just run them.

#### deb

You can add our repository to your package manager by running

```
echo "deb [trusted=yes] https://apt.fury.io/notion-repackaged/ /" | sudo tee /etc/apt/sources.list.d/notion-repackaged.list
```

> :information_source: For the new repository to be able to provide our packages, you will have to run `sudo apt update` first

With that you will be able to install `notion-app` or `notion-app-enhanced` using `sudo apt install <package name>`

Alternatively, download manually and run `sudo dpkg -i <downloaded file>.deb` to install the package.

#### rpm

> :warning: These instructions assume you are using dnf/yum in Fedora or alikes. Instructions might vary depending on the distribution you are using.

You can add our repository to your package manager by creating the file `/etc/yum.repos.d/notion-repackaged.repo` with the following contents:

```
[notion-repackaged]
name=Notion Repackaged Repo
baseurl=https://yum.fury.io/notion-repackaged/
enabled=1
gpgcheck=0
```

With that you will be able to install `notion-app` or `notion-app-enhanced` using `sudo dnf install <package name>`

Alternatively, download manually and run `sudo rpm -i <downloaded file>.rpm` to install the package.

#### pacman

You can install the [notion-app](https://aur.archlinux.org/packages/notion-app/) or [notion-app-enhanced](https://aur.archlinux.org/packages/notion-app-enhanced) packages for the vanilla or enhanced versions respectively.

Alternatively, download manually and run `sudo pacman -U <downloaded file>.pacman` to install the package.

### MacOS

> :warning: As of now, the M1 (arm64) build is non-functional due to [electron-userland/electron-builder#5850](https://github.com/electron-userland/electron-builder/issues/5850), you can try using the regular build thanks to Rosetta. You can also try using the arm64 zip build that might work.

We also build the enhanced variant for MacOS but there are no concrete instructions as I have no way of trying the builds for myself.

In theory, you should be able to download the `dmg` build and drag it to your dock to install it.

The dmg archive produced is not signed, so chances are you'll not be able to use it, or even install it.

Please, take look at the official instructions from Apple on how to install unsigned apps: https://support.apple.com/en-us/HT202491

## Issues

If you find yourself not being able to use our builds, please create an issue with any and all information you can provide on how to reproduce and debug this issue. Screenshots and terminal logs are vital to being able to reproduce and fix the issues.

If you have an issue with the enhanced variant, please try using the vanilla variant. This step is crucial on the way to figuring our the root of the issue. Do not create issues in notion-enhancer before making sure it's not our fault, we modify notion-enhancer's internals heavily.

## Contributing

Any contribution is welcome, be it documentation, code improvements or fixes.
We don't plan on improving notion-enhancer, we aim to be compatible with it and track their changes.

## Disclaimer

This project extracts the source code of the publicly-available binaries on the [official Notion website](https://www.notion.so/desktop), meaning all code contained within our packages is owned by Notion.

Additionally, in the enhanced variant, we embed [notion-enhancer](https://github.com/notion-enhancer/notion-enhancer) which is MIT licensed. All code contained in the `embedded_enhancer` directory and the icons in the `assets` directory are owned by them.

This project is made as a best-effort, integrating and supporting all Linux distributions as well as other OSes like Mac and Windows is very complicated. 

We are not liable for any problems caused by this (or included) software.
