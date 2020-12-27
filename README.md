# server-with-s3fs

Use Terraform to provision an EC2 instance with S3FS installed.

## The Cloud Init Process

Formats and mounts the data disk.

LOG FILES - New logs are appended for each reboot.

   /var/log/cloud-init-output.log
     captures the output from each stage of cloud-init when it runs

   /var/log/cloud-init.log
     very detailed log with debugging output, detailing each action taken

   /run/cloud-init
     contains logs about how cloud-init decided to enable or disable itself,
     as well as what platforms/datasources were detected. These logs are most 
     useful when trying to determine what cloud-init ran or did not run.

See https://cloudinit.readthedocs.io/en/latest/topics/faq.html for more information.
