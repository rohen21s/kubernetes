# Proxmox Installation

## Step 1 - Download latest proxmox ISO
- [Download Latest Proxmox ISO](https://proxmox.com/en/downloads)
___
## Step 2 - Boot Proxmox ISO USB
- [Download RUFUS Portable](https://rufus.ie/es/)
___
## Step 3 - Proxmox installation steps
### Step 3.1 - Set valid FQDN

- [Examples how to define personalized FQDN](https://www.cloudns.net/blog/fqdn-fully-qualified-domain-name/)

> **[hostname].[domain].[tld]**   

> Similar to the following example: **machine01.example.zyx**
___
### Step 3.2 - Select networking interface (enp0s or wifi)

> The shown IPs such as 192.168.100.X are initial basic configured IPs from `/etc/netplan/50..` or `/etc/network/interfaces`, don't worry on the following step we change the network configuration.

___

# Proxmox Initial Setup / Configuration
## 1# Network basic configuration

> Assuming you have your PROXMOX server connected to the router directly via Eth or WiFi.

- 1.1.- Verify what interfaces you own, and which is the base configuration currently set with `ip a`.<br><br/> 
At first boot or initial startup, we can see that the **_iface_** uses some random IP `192.168.100.2`, which is not from within our home network that usually is `192.168.x.x/24)`.<br/><br/>
Therefore what we need to do here, is request to our DHCP one within the correct range of our home LAN Internet range `(For example my DHCP range was 192.168.1.128 -> 192.168.1.249)`.<br/><br/>

- 1.2.- We must request a lease, this way the router selects, a new IP from our DHCP server at home with the following command; make sure you use your Iface ID<br/>

> `dhclient enp0s1`

> `ip a` # to see your new IP

- 1.3.- Modify `sudo nano /etc/network/interfaces` according to your IP and MASK. Example: 

```sh
# /etc/network/interfaces
root@proxmonster:~# cat /etc/network/interfaces
auto lo
iface lo inet loopback

iface enp1s0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 192.168.1.138/24
        gateway 192.168.1.1
        netmask 255.255.255.0
        nameserver 8.8.8.8
        nameserver 8.8.4.4
        nameserver 1.1.1.1
        bridge-ports enp1s0
        bridge-stp off
        bridge-fd 0

iface wlo1 inet manual

source /etc/network/interfaces.d/*
```

- 1.4.- Activate IP forwarding: `sudo echo 1 > /proc/sys/net/ipv4/ip_forward`

```
IP Forwarding: IP forwarding is the ability of a Linux system to route packets between network interfaces. By default, Linux systems do not forward packets between interfaces, which means they only process packets destined for their own IP addresses.
```

- 1.5.- Restart the service networking
`sudo service networking restart` 

- 1.6.- Edit `/etc/hosts/` file. Adding new IP as your new hostname. Example:
```sh
root@proxmonster:~# cat /etc/hosts
127.0.0.1 localhost.localdomain localhost
#192.168.100.2 proxmonster.rohenslab.xyz proxmonster
192.168.1.138 proxmonster.rohenslab.xyz proxmonster

# The following lines are desirable for IPv6 capable hosts

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
root@proxmonster:~#
```

- 1.7.- Verification step `ip a` verify that the IPs haven't been removed, your defined IP is there and stable, finally ping `8.8.8.8` or `google.com`.
___

## 2# Update proxmox No subscription

- 2.1.- Edit `/etc/apt/sources.list` add these commented lines: 

```sh
# /etc/apt/sources.list                                             

deb http://ftp.es.debian.org/debian bookworm main contrib

deb http://ftp.es.debian.org/debian bookworm-updates main contrib

# security updates
deb http://security.debian.org bookworm-security main contrib

# not for production use
deb http://download.proxmox.com/debian bookworm pve-no-subscription

# bookworm pbs-no-sub
deb http://download.proxmox.com/debian/pbs bookworm pbstest
```

- 2.2.- To avoid errors when updating comment the following line; in the file `/etc/apt/sources.list.d/pve-enterprise.list`.

> `#deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise`

- 2.3.- Comment one more line at `/etc/apt/sources.list.d/ceph.list`.

>`# deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise`

- 2.4.- `apt-get update && upgrade`
___
## 3# Enable IOMMU

- Access to grub file `nano /etc/default/grub`. Comment a line and add the below one, choose if you have `AMD` or `Intel` processor.
```
#GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"
#GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on"
```

- `Save it`

- `uptate-grub`

- `nano /etc/modules` add the following tags:

```sh
# /etc/modules: kernel modules to load at boot time.
#
# This file contains the names of kernel modules that should be loaded
# at boot time, one per line. Lines beginning with "#" are ignored.
# Parameters can be specified after the module name.

vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```
___
## 4# VLAN Aware

- Enable VLAN Aware checkbox as in the following image.

![VLAN Aware checkbox on](image.png)

___

# Virtual Machine prepparation
## 1# Preparing machines (basic netw and host config)

Requirements before begin:

>- 1 VM debian or ubuntu for Master node
>- 2 VMs debian or ubuntu for Worker nodes
>- 40 Gb storage 2Gb RAM good to go
 
- Check your leased and assigned IPs by your home LAN network DHCP, with `ifconfig` or `ip a` to utilize the mentioned commands install; `net-tools` and `ifupdown`.

> Copy or write down the assigned IPv4 for the next step.

- Check connectivity if you can download updates, `ping 8.8.8.8` proceed with the next steps.
- Do `sudo apt update`
- Do `sudo apt install ifupdown net-tools`
- To make sure that the newly assigned IP to the machine configuration is fixated permanently on the machine, we will edit `/etc/netplan/50-cloud-init.yaml` file as in the example below; we do that just in case our Home DHCP lease a new IP and tries to change it.
- Additionally you can `DHCP Bind IP+Mac on your Router settings`.
- The file is`sudo nano /etc/netplan/50-cloud-init.yaml` the following example can be applicable to your use case only change IPs to yours.
```sh
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        ens18:
             addresses: [192.168.1.132/24]
             routes:
                 - to: default
                   via: 192.168.1.1
```
- Make sure we test this with `sudo netplan try` and `ENTER` if no issues.
- Check hostnames `cat /etc/hosts && cat /etc/hostname`. Make sure the machine name is correctly set there.
- Make sure `/etc/resolv.conf` doesn't contain anything strange because otherwise can break cluster's DNS initial configurations.

```sh
# This is /run/systemd/resolve/stub-resolv.conf managed by man:systemd-resolved(8).
# Do not edit.
#
# This file might be symlinked as /etc/resolv.conf. If you're looking at
# /etc/resolv.conf and seeing this text, you have followed the symlink.
#
# This is a dynamic resolv.conf file for connecting local clients to the
# internal DNS stub resolver of systemd-resolved. This file lists all
# configured search domains.
#
# Run "resolvectl status" to see details about the uplink DNS servers
# currently in use.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 127.0.0.53
options edns0 trust-ad
search .
```

- `sudo apt install qemu-guest-agent`
- `sudo apt update` `sudo apt upgrade`

``` 
    # Kubectl Autocomplete - kubectl
    
    alias k=kubectl
    complete -o default -F __start_kubectl k
    
    export do="--dry-run=client -o yaml"
    export now="--force --grace-period 0"
     
    set tabstop=2
    set expandtab
    set shiftwidth=2
     
    source <(kubectl completion bash) # set up autocomplete in bash into the current shell, bash-completion package should be installed first.
    echo "source <(kubectl completion bash)" >> ~/.bashrc # add autocomplete permanently to your bash shell.
```

___
## 2# Preparing machines (must do, before init cluster)

- Check UUID are unique with `sudo cat /sys/class/dmi/id/product_uuid`.
- Check if swap is in use, To disable swap, sudo `swapoff -a` can be used to disable swapping `!! temporarily !!`.
- Method to **permanently disable Swap**. Edit the `/etc/fstab` file using a text editor like sudo vi `/etc/fstab` or `sudo nano /etc/fstab`.
- Comment out the swap partition or file by adding a # symbol at the beginning of the line. For example:

>`#/swap.img      none    swap    sw      0       0 `

```sh
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/ubuntu-vg/ubuntu-lv during curtin installation
/dev/disk/by-id/dm-uuid-LVM-HASHXXXXXX / ext4 defaults 0 1
# /boot was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/HASHXXXXXX /boot ext4 defaults 0 1
#/swap.img      none    swap    sw      0       0  <----- COMMENT THIS LINE AND SAVE FILE
```
- Save the changes and exit the editor.
- Reload system configurations, `sudo systemctl daemon-reload` and optionally reboot to ensure the changes take effect `sudo reboot`.
- Verify Swap Disabled `free -h`.

```               total        used        free      shared  buff/cache   available
Mem:           5.9Gi       1.1Gi       2.1Gi       2.8Mi       2.9Gi       4.7Gi
Swap:             0B          0B          0B
```
___
# Cluster setup and component installation
## 1# (All Nodes) Installing containeruntime

- Install **containerd** on all machines `sudo apt install containerd`
- Check status on all machines `sudo service containerd status`
- Create a **dir** for containerd `sudo mkdir /etc/containerd`
- Import basic config for containerd `containerd config default | sudo tee /etc/containerd/config.toml` make sure the config.toml file is created `ls -l /etc/containerd`.
- Change `SystemdCgroup` to `true` in the file `sudo nano /etc/containerd/config.toml`
- Verify swap is disabled `free -h` in `/etc/fstab` the line with type `swap` must be commented.
- Enable `net.ipv4.ip_forward=1` in the file `sudo nano /etc/sysctl.conf`.
- Create a file `/etc/modules-load.d/k8s.conf` add `br_netfilter`
- Reboot after these changes.</br>

___
## 2# (All Nodes) Cluster component installation

### 2.1# (All Nodes) Certificate management

- These instructions are for Kubernetes v1.31, update the apt package index and install packages needed to use the Kubernetes apt repository:
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```
- Download the public signing key for the Kubernetes package repositories. 
- The same signing key is used for all repositories so you can disregard the version in the URL:
- If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.

```
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
- Add the appropriate Kubernetes apt repository. Please note that this is for Kubernetes 1.31 version.
```
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

- Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:
```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

- (Optional) Enable the kubelet service before running kubeadm:

```
sudo systemctl enable --now kubelet
```
___


## 3# (Master Only) Kubeadm Init

- We initialize the cluster with the `kubeadm init` command, **very important step here**, if you will use Calico as CNI Plugin fill all the parameters and specially `--pod-network-cidr` is required for Calico CNI Plugin, as you can see on the following command:

```
sudo kubeadm init --control-plane-endpoint=192.168.1.132 --node-name=monstrussy-master --pod-network-cidr=192.168.0.0/18 --apiserver-advertise-address=192.168.1.132
```

- Once you see the output `"Your Kubernetes control-plane has initialized successfully!"` after `kubeadm init` command generate `.kube/config files`, to start using your cluster, you need to run the following as a regular user:

```
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
```
Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf
```

- With the following command example, send a copy of your `./kube` folder to all your node machines that will join to the fleet / cluster, this will allow you to use `kubectl` commands from `worker nodes`.
```
  #Copy command ( scp -r <SRC_DIR> <DST_HOST_USER>@<DST_HOST_IP>:<DST_DIR> )
  scp -r .kube/ rohen@192.168.1.133:/home/rohen/.kube
```

___
## 4# (Master Only) Installing CNI Plugin

- Immediately after cluster initialization your cluster requires the CNI plugin that configures all networking for Pods on your cluster.</br></br>
- Calico CNI Network plugin installation steps / all the commands:

```sh
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

#Remove the taints on the control plane so that you can schedule pods on it.
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

swapoff -a

strace -eopenat kubectl version

service kubelet restart

service containerd restart

kubectl get nodes -o wide

kubectl get pods -A -o wide
```

> If you face any issues from the provided commands, check their current versions and steps in the [Calico official docmentation](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises).


- Flannel CNI Network plugin installation steps:

```sh
#Apply the Flannel network configuration using the following command:
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#Remove the taints on the control plane so that you can schedule pods on it.
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

swapoff -a

strace -eopenat kubectl version

service kubelet restart

service containerd restart

kubectl get nodes -o wide

kubectl get pods -A -o wide
```

> If you face any issues from the provided commands, check their current versions and steps in the [Flannel official docmentation](https://github.com/flannel-io/flannel#deploying-flannel-manually).

___

## 5# (Worker Nodes) kubeadm join

> In the MASTER NODE obtain the token to join fleet.

- Run `kubeadm token create --print-join-command`

> SSH into your WORKER NODES

- Join the cluster fleet with the obtained token and command from MASTER:

>`sudo kubeadm join 192.168.1.132:6443 --token XXXX.XXXXXX --discovery-token-ca-cert-hash sha256:XXXXXXXXXXXXXXXX`

- You are good to go now with the nodes added to the cluster. If you receive `connection refused`, by typing `kubectl` commands, make sure you performed this step:
- With the following command example, send a copy of your `./kube` folder to all your node machines that will join to the fleet / cluster, this will allow you to use `kubectl` commands from `worker nodes`.
```
  #Copy command ( scp -r <SRC_DIR> <DST_HOST_USER>@<DST_HOST_IP>:<DST_DIR> )
  scp -r .kube/ rohen@192.168.1.133:/home/rohen/.kube
 
  swapoff -a
    
  strace -eopenat kubectl version
    
  service kubelet restart
    
  service containerd restart
    
  kubectl get nodes -o wide
    
  kubectl get pods -A -o wide
```

