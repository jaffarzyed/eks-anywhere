#!/bin/bash
read -p 'vSphere Datacenter name: ' vsphere_datacenter
read -p 'vSphere Default Templates folder, e.g. Templates: ' vsphere_templates_folder
read -p 'Final name for EKS-A ubuntu node template, e.g. ubuntu-2004-kube-v1.21.14: ' ubuntu_template_name
read -p 'vSphere Resource pool name, e.g. Test: ' vsphere_resource_pool
sudo -Hiu ubuntu eksctl anywhere download artifacts
sudo -Hiu ubuntu tar -xzf eks-anywhere-downloads.tar.gz
export eksd_release_tag=$(file=$(sudo -Hiu ubuntu ls eks-anywhere-downloads/1.21/eks-distro/ | grep kubernetes) | \
echo $file| rev | awk -v FS='.' '{print $2}' | rev)
vsphere_content_library=eks-anywhere-template-$RANDOM
govc library.create "$vsphere_content_library"
sed -i "s/vsphere_content_library/$vsphere_content_library/g" $HOME/vsphere-connection.json
image-builder build --os ubuntu --hypervisor vsphere --release-channel 1-21 --vsphere-config $HOME/vsphere-connection.json
export vsphere_templates_folder_full_path=/$vsphere_datacenter/vm/$vsphere_templates_folder
cp ubuntu.ova $ubuntu_template_name.ova
govc library.import $vsphere_content_library /home/image-builder/$ubuntu_template_name.ova
govc library.deploy -pool $vsphere_resource_pool -folder $vsphere_templates_folder_full_path /$vsphere_content_library/$ubuntu_template_name $ubuntu_template_name
govc snapshot.create -vm $ubuntu_template_name root
govc vm.markastemplate $ubuntu_template_name
govc tags.create -c os os:ubuntu
govc tags.category.create -t VirtualMachine eksdRelease
govc tags.create -c eksdRelease eksdRelease:$eksd_release_tag
govc tags.attach os:ubuntu $vsphere_templates_folder_full_path/$ubuntu_template_name
govc tags.attach eksdRelease:$eksd_release_tag $vsphere_templates_folder_full_path/$ubuntu_template_name
govc library.rm "$vsphere_content_library"
sed -i "s/$vsphere_content_library/vsphere_content_library/g" $HOME/vsphere-connection.json
