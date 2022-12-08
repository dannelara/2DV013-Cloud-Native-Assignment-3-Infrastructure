### Install OS Packages

> sudo apt-get update

> sudo apt install nfs-kernel-server -y

### Create Directories

> sudo mkdir -p /data

> sudo chown nobody:nogroup /data

> sudo chmod g+rwxs /data

### Sharing the Directories / Export the Directory

> sudo echo -e "/data\t172.16.0.0/16(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports

> sudo exportfs -av

CREATE TABLE COLOR(
ID SERIAL PRIMARY KEY NOT NULL,
NAME TEXT NOT NULL UNIQUE,
RED SMALLINT NOT NULL,
GREEN SMALLINT NOT NULL,
BLUE SMALLINT NOT NULL
);

INSERT INTO COLOR (NAME,RED,GREEN,BLUE) VALUES('GREEN',0,128,0);

SELECT \* FROM COLOR;
