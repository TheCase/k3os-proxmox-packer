#!/bin/bash
mkdir -p files
KEYNAME="k3os.pem"
yes | ssh-keygen -t rsa -N '' -f ${KEYNAME} -C 'rancher@k3os'

echo

if [ -z files/install.sh ]; then 
  echo Downloading install script...
  curl -s https://raw.githubusercontent.com/rancher/k3os/master/install.sh -o files/install.sh
fi

LATEST=$(curl -isS https://github.com/rancher/k3os/releases/latest | grep "location:" | sed "s/^.*\/\(v[0-9.]*\).*/\1/")
echo Current k3os version: ${LATEST}
export K3S_URL=https://github.com/rancher/k3os/releases/download/${LATEST}/k3os-amd64.iso

echo ISO_URL: ${K3S_URL}
export K3S_MD5=$(curl -sSL https://github.com/rancher/k3os/releases/download/${LATEST}/sha256sum-amd64.txt | grep iso | awk {'print $1'})
echo k3os iso md5: ${K3S_MD5}

echo
echo creating config from template...
SSHKEY=$(cat ${KEYNAME}.pub)
sed "s#{{SSHKEY}}#${SSHKEY}#g" config.template > files/config.yaml

cat <<EOT > sshkey.json
{
  "authorized_keys" : "${SSHKEY}"
}
EOT

echo
echo config template created.  Your private key has been copied as ~/.ssh/${KEYNAME}

echo building image...
#PACKER_LOG=1 packer build -var-file=variables.json -var-file=sshkey.json k3os-proxmox.json
packer build -var-file=variables.json -var-file=sshkey.json k3os-proxmox.json
echo done.
