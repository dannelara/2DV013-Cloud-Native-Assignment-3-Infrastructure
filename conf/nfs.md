### Install OS Packages

> sudo apt-get update

> sudo apt install nfs-kernel-server -y

### Create Directories

> sudo mkdir -p /data

> sudo chown nobody:nogroup /data

> sudo chmod g+rwxs /data

###

Security groups are configured by the openstack client so we do not need to allow ports or change the ufw etc.

### Sharing the Directories / Export the Directory

> sudo echo -e "/data\t172.16.0.0/16(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports

> sudo exportfs -av

## DONE!

/sbin/showmount -e <ip>

<!-- ## Postgres exec command.

kubectl exec -it [pod-name] -- psql -h localhost -U user --password -p 5432 db -->
