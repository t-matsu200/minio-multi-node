Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/sh

sudo dnf update -y 
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo dnf install -y curl jq
sudo systemctl enable amazon-ssm-agent --now

sudo dnf install -y https://dl.min.io/server/minio/release/linux-amd64/archive/minio-20241218131544.0.0-1.x86_64.rpm

sudo mkdir -p /mnt/disk1 /mnt/disk2 /mnt/disk3 /mnt/disk4

sudo mkfs -t xfs ${ebs_volume1}
sudo mkfs -t xfs ${ebs_volume2}
sudo mkfs -t xfs ${ebs_volume3}
sudo mkfs -t xfs ${ebs_volume4}

sudo tee -a /etc/fstab <<EOF

${ebs_volume1} /mnt/disk1 xfs defaults,nofail 0 2
${ebs_volume2} /mnt/disk2 xfs defaults,nofail 0 2
${ebs_volume3} /mnt/disk3 xfs defaults,nofail 0 2
${ebs_volume4} /mnt/disk4 xfs defaults,nofail 0 2
EOF

sudo mount -a

sudo groupadd -r minio-user
sudo useradd -M -r -g minio-user minio-user
sudo chown minio-user:minio-user /mnt/disk1 /mnt/disk2 /mnt/disk3 /mnt/disk4

sudo tee -a /etc/hosts <<EOF

${ec2_node_ip1} minio1.tmatsuno.com
${ec2_node_ip2} minio2.tmatsuno.com
${ec2_node_ip3} minio3.tmatsuno.com
${ec2_node_ip4} minio4.tmatsuno.com
EOF

sudo tee /usr/lib/systemd/system/minio.service <<EOF >/dev/null
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"\$${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server --console-address :9001 \$${MINIO_VOLUMES}

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemctl setups where other services use `After=minio.server`
# Uncomment the line to enable the functionality
# Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for minio-multi-node
EOF

sudo tee /etc/default/minio <<EOF >/dev/null
# Set the hosts and volumes MinIO uses at startup
# The command uses MinIO expansion notation {x...y} to denote a
# sequential series.
#
# The following example covers four MinIO hosts
# with 4 drives each at the specified hostname and drive locations.
# The command includes the port that each MinIO server listens on
# (default 9000)

MINIO_VOLUMES="http://minio{1...4}.tmatsuno.com:9000/mnt/disk{1...4}/minio"

# Set the root username. This user has unrestricted permissions to
# perform S3 and administrative API operations on any resource in the
# deployment.
#
# Defer to your organizations requirements for superadmin user name.

MINIO_ROOT_USER=28oT5FmfQnw3HtBm

# Set the root password
#
# Use a long, random, unique string that meets your organizations
# requirements for passwords.

MINIO_ROOT_PASSWORD=56cwgyrgl3seLecG
EOF

sudo systemctl start minio.service
sudo systemctl enable minio.service
