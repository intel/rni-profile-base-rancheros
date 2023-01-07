DISCONTINUATION OF PROJECT

This project will no longer be maintained by Intel.

Intel has ceased development and contributions including, but not limited to, maintenance, bug fixes, new releases, or updates, to this project.  

Intel no longer accepts patches to this project.

If you have an ongoing need to use this project, are interested in independently developing it, or would like to maintain patches for the open source software community, please create your own fork of this project.  

Contact: webadmin@linux.intel.com
# Rancher OS Profile

Intended to be used with [Retail Node Installer](https://github.com/intel/retail-node-installer), this Rancher OS profile contains a few files that ultimately will install Rancher OS v1.5.1 to disk.

## Getting Started

**A necessary prerequisite to using this profile is having an Retail Node Installer deployed**. Please refer to its documentation in order to deploy it.

Out of the box, the Rancher profile should _just work_. Therefore, no specific steps are required in order to use this profile that have not already been described in the Retail Node Installer documentation. Simply boot a client device using legacy BIOS PXE boot and the Rancher profile should automatically launch after a brief waiting period. _Note that RancherOS itself does not support UEFI installation._

If you do encounter issues PXE booting, please review the steps outlined in the [Retail Node Installer documentation](https://github.com/intel/retail-node-installer) and ensure you've followed them correctly. See the [Known Issues](#Known-Issues) section for possible solutions.

After installing Rancher, the default login username is `rancher` and the default password is `P@ssw0rd!`. This password is defined in the `bootstrap.sh` script and in the `conf/config.yml` as a kernel argument.

## Boot Process

This RancherOS profile sets this kernel argument in `conf/config.yml`:

```
rancher.cloud_init.datasources=[url:http://@@HOST_IP@@/profile/@@PROFILE_NAME@@/dyn-ks.yml]
```

The Rancher initrd uses [cloud init](https://cloud-init.io/) to process the file called `dyn-ks.yml`, which is a [kickstart](https://en.wikipedia.org/wiki/Kickstart_(Linux)) file that contains a few bash script definitions. The last step of this kickstart is to run `wget` to download `bootstrap.sh` from the Retail Node Installer, which is then executed in a shell. Inside the `bootstrap.sh` file is a minimal script that installs Rancher to disk using `ros install`.

## Known Issues

Currently, the `bootstrap.sh` file does not properly tell the Rancher installer to use `dyn-ks.yml`. In future releases this will be fixed.

This profile is not intended to provide a completely functional operating system. Please use this profile as reference code to build out your own operating systems to your own needs.

## Customization

If you want to customize your Retail Node Installer profile, follow these steps:

* Duplicate this repository locally and push it to a separate/new git repository
* Make changes after reading the information below
* Update your Retail Node Installer configuration to point to the git repository and branch (such as master).

The flexibility of Retail Node Installer comes to fruition with the following profile-side file structures:

* `conf/config.yml` - This file contains the arguments that are passed to the Linux kernel upon PXE boot. Alter these arguments according to the needs of your scripts. The following kernel arguments are always prepended to the arguments specified in `conf/config.yml`:
  * `console=tty0`
  * `httpserver=@@HOST_IP@@`
  * `bootstrap=http://@@HOST_IP@@/profile/${profileName}/bootstrap.sh`
* `conf/files.yml` - This file contains a few definitions that tell Retail Node Installer to download specific files that you can customize. **Please check if there are any [Known Issues](#Known-Issues) before changing this file from the default.** See `conf/files.sample.yml` for a full example.
* `bootstrap.sh` - A profile is required to have a `bootstrap.sh` as an entry point. This is an arbitrary script that you can control. If you plan to create profiles for other operating systems such as Ubuntu or Debian, it is recommended to use [preseed](https://wiki.debian.org/DebianInstaller/Preseed) to launch `bootstrap.sh` as the last step.
* `*.rnitemplate` - Any file under any directory (for example `dyn-ks.yml.rnitemplate`) will be processed into its intended file (becoming`dyn-ks.yml`). Currently the following variables are processed:
  * `@@DHCP_MIN@@`
  * `@@DHCP_MAX@@`
  * `@@NETWORK_BROADCAST_IP@@`
  * `@@NETWORK_GATEWAY_IP@@`
  * `@@HOST_IP@@`
  * `@@NETWORK_DNS_SECONDARY@@`
  * `@@PROFILE_NAME@@`

### Customization Requirements

A profile **must** have all of the following:

* a `bootstrap.sh` file at the root of the repository
* a `conf/files.yml` specifying an `initrd` and `vmlinuz`, as shown in the `conf/files.yml` file.

### Upgrading Rancher

To update rancher, you will need to connect to the rancher system and run the `ros os upgrade` command.

You will also need to provide the `-i` command line argument with the rancher version you would like to upgrade to. Rancher versions are stored in the official rancher git repository found [here](https://github.com/rancher/os/releases)

```bash
ros os upgrade -i rancher/os:<UPDATE_VERSION>
```

Follow the user prompts to complete the process

If you would like to automate the update and skip the user prompts run yes as the default answer. You can do this by using the example below.

```bash
yes Y | ros os upgrade -i rancher/os:<UPDATE_VERSION>
```