##Packer k3os template builder for Proxmox

This will create a clonable k3os template in your Proxmox cluster.  

- creates and applies ssh keys for cloned guests 
  - k3os.pem
  - k3os.pem.pub 
- patches qemu-guest-agent for provisioner step

#### Usage:

create a `variables.json` from `variables.json-example`, replacing with details pertinent to your environment.

Run:

```
./build.sh
```

At the end of the run, you'll have fresh ssh keys to access any freshly booted clones.


### Questions, support?  

Please file an issue in the project tracker.
