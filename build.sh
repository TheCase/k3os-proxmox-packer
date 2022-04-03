#!/bin/bash
CACHE=packer_cache/build
mkdir -p ${CACHE}
echo generating SSH keys...
KEYNAME="k3os_new.pem"
yes | ssh-keygen -t ed25519 -N '' -f ${CACHE}/${KEYNAME} -C 'rancher@k3os'
exit

echo

if [ ! -f ${CACHE}/install.sh ]; then 
  echo Downloading install script...
  curl -s https://raw.githubusercontent.com/rancher/k3os/master/install.sh -o ${CACHE}/install.sh
fi

LATEST=$(curl -isS https://github.com/rancher/k3os/releases/latest | grep "location:" | sed "s/^.*\/\(v[0-9.a-z-]*\)\r/\1/")
echo Current k3os version: ${LATEST}
export K3S_URL=https://github.com/rancher/k3os/releases/download/${LATEST}/k3os-amd64.iso

echo ISO_URL: ${K3S_URL}
K3S_MD5_URL="https://github.com/rancher/k3os/releases/download/${LATEST}/sha256sum-amd64.txt"
export K3S_MD5=$(curl -sSL ${K3S_MD5_URL} | grep iso | awk {'print $1'})
echo k3os iso url: ${K3S_MD5_URL}
echo k3os iso md5: ${K3S_MD5}

echo
echo creating config from template...
SSHKEY=$(cat ${CACHE}/${KEYNAME}.pub)
sed "s#{{SSHKEY}}#${SSHKEY}#g" templates/config.template > ${CACHE}/config.yaml

cat <<EOT > ${CACHE}/sshkey.json
{
  "authorized_keys" : "${SSHKEY}"
}
EOT

echo
cp -v ${CACHE}/${KEYNAME}* ~/.ssh/.
echo config template created.  Your private key has been copied to ~/.ssh/${KEYNAME}

echo building image...
PACKER_LOG=1 packer build -var-file=variables.json -var-file=${CACHE}/sshkey.json k3os-proxmox.json
#packer build -var-file=variables.json -var-file=${CACHE}/sshkey.json k3os-proxmox.json
echo done.
