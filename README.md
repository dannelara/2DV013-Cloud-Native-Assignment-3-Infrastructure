# 2DV013-Cloud-Native-Assignment-3-Infrastructure

# How to Setup Kubernetes Cluster with cloud-init on Ubuntu 22.04

1. Download your PEM file and your OpenStack RC file.
2. Rename the `example.terraform.tfvars` file to `terraform.tfvars` in the projects directory and assign suitable values to `keypair` and `pem_file_path`.
3. Open a Bash terminal and change to the directory containing the Terraform configuration files if necessary.
4. Run the `terraform init` command to initialize a working directory.

   ```text
   terraform init
   ```

5. Run the `terraform apply` command (source in your OpenStack RC file that you previously downloaded, to set the required environment variables).

   ```text
   source ym222cw-openrc.sh && terraform apply --auto-approve
   ```

6. The execution of the actions in the plan takes several minutes to complete. If the execution fails, just restart it again. (If necessary, run the `terraform destroy` command to destroy all objects before restarting the execution.)
   > 👉 If you find that it takes a long time, several minutes, for OpenStack to create an instance, you can use OpenStack's web interface to delete the instance that seems to have hung. The execution is canceled, and you can run the `terraform apply` command again.
7. After creating the control plane node server, you can use SSH to connect to the server and wait for cloud-init to complete successfully.

   ```text
   ssh -o StrictHostKeyChecking=no -i ym222cw_key_ssh.pem ubuntu@<ip>
   ```

   ```text
   ubuntu@k8s-control-plane:~$ cloud-init status --wait
   ```

   > The server may reboot, in which case you will need to reconnect and run the `cluster-init` command again.

8. Once the initialization is complete, check that everything is working so far.

   ```text
   ubuntu@k8s-control-plane:~$ kubectl cluster-info
   Kubernetes control plane is running at https://172.16.0.14:6443
   CoreDNS is running at https://172.16.0.14:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
   ```

   ```text
    ubuntu@k8s-control-plane:~$ kubectl get nodes -o wide
    NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
    k8s-control-plane   Ready    control-plane   32m   v1.25.4   172.16.0.14   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.9
   ```

9. Once the initialization of the worker node servers is complete, they are ready to join the cluster.

   ```text
   ubuntu@k8s-control-plane:~$ ./bin/worker-init.sh 172.16.0.16 172.16.0.10 172.16.0.6
   172.16.0.16 joining cluster
   172.16.0.10 joining cluster
   172.16.0.6 joining cluster

   <OMITTED>

   This node has joined the cluster:
   * Certificate signing request was sent to apiserver and a response was received.
   * The Kubelet was informed of the new secure connection details.

   Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
   ```

10. Use the `kubectl get nodes` command to retrieve information from the Kubernetes cluster.

    ```text
    ubuntu@k8s-control-plane:~$  kubectl get nodes -o wide
    NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
    k8s-control-plane   Ready    control-plane   14h   v1.25.4   172.16.0.14   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.9
    k8s-worker-1        Ready    <none>          13h   v1.25.4   172.16.0.16   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.9
    k8s-worker-3        Ready    <none>          13h   v1.25.4   172.16.0.6    <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.9
    ```

    Ooops, only two of three workers have joined!

    ```text
    ubuntu@k8s-control-plane:~$  ./bin/worker-init.sh 172.16.0.10
    172.16.0.10 joining cluster
    ubuntu@172.16.0.10: Permission denied (publickey).
    ```

    If there is still a problem with the missing worker node joining, try rebooting the worker instance and then try to join again. You can use OpenStack's web interface to reboot the failing instance by the Hard Reboot Instance command.

    Still, having trouble getting the worker node to connect after the reboot? Remove the instance and try again after it has been created and initialized.

11. Verify the cluster again and note (hopefully) that all worker nodes have joined.

    ```text
    ubuntu@k8s-control-plane:~$ kubectl get nodes -o wide
    NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
    k8s-control-plane   Ready    control-plane   14h   v1.25.4   172.16.0.14   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.9
    k8s-worker-1        Ready    <none>          14h   v1.25.4   172.16.0.16   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.9
    k8s-worker-2        Ready    <none>          14m   v1.25.4   172.16.0.10   <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.10
    k8s-worker-3        Ready    <none>          14h   v1.25.4   172.16.0.6    <none>        Ubuntu 22.04.1 LTS   5.15.0-53-generic   containerd://1.6.9
    ```

12. If you use Helm to manage Kubernetes applications, you may need to point to the Kubernetes configuration file, `~/.kube/config` explicitly.

    ```text
    sudo helm repo add bitnami https://charts.bitnami.com/bitnami
    sudo helm repo update
    sudo helm install mongodb bitnami/mongodb --kubeconfig ~/.kube/config
    ```

---

<blockquote>

## How to Setup Kubernetes Cluster on Ubuntu 22.04 - a hands-on experience

Do you like to be in control and don't like cloud-init? Below, you will find the necessary steps to create a cluster.

(Use SSH to connect to the instances.)

### Setup the control plane node and worker nodes

#### Update and upgrade the system

```text
$ sudo apt update

$ sudo apt upgrade -y

$ sudo reboot
```

#### Enable kernel modules and disable SWAP

```text
$ sudo modprobe overlay
$ sudo modprobe br_netfilter

$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

$ sudo sysctl --system

$ sudo swapoff -a
$ sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
$ free -m
```

#### Installing container runtime: containerd

```text
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

$ sudo apt update

$ sudo apt install containerd.io

$ sudo systemctl stop containerd

$ sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.orig
$ sudo touch /etc/containerd/config.toml
$ sudo chmod +w /etc/containerd/config.toml
$ sudo containerd config default > /etc/containerd/config.toml

$ sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

$ sudo systemctl start containerd

$ sudo systemctl is-enabled containerd
$ sudo systemctl status containerd
```

#### Installing Kubernetes package

```text
$ sudo apt install apt-transport-https ca-certificates curl -y

$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

$ sudo apt update && sudo apt upgrade -y

$ sudo apt install -y kubelet kubeadm kubectl

$ sudo apt-mark hold kubelet kubeadm kubectl
```

### Initializing the control plane node

```text
$ sudo kubeadm config images pull
$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16

$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

$ kubectl cluster-info

$ kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

$ kubectl cluster-info
$ kubectl get pods -A
$ kubectl get nodes -o wide
```

### Initializing the worker nodes

On the control plane machine!

```text
$ JOIN="'sudo $(kubeadm token create --print-join-command)'"

$ ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/ssh_private_key.pem ubuntu@<your worker ip> 'bash -c' $JOIN

$ kubectl get nodes -o wide
```

</blockquote>
