
# Increasing CRC disk space

Below are steps to give your CRC instance more disk space. E.g. if you run out of ephemeral-space while experimenting with ODH.

Unlike setting the nuber of CPUs or available memory increasing the disk image is not direcly supported by CRC.

First you can check your current image size. Do it with CRC turned off:

``` sh
qemu-img info ~/.crc/machines/crc/crc | grep 'virtual size'
virtual size: 31 GiB (33285996544 bytes)
```

By default you will see something similar as above.

Then you can grow the quemu size:

``` sh
qemu-img resize ~/.crc/machines/crc/crc +32G
```

Start CRC again:

``` sh
crc start
```

Log is and grow the filesystem:

``` sh
ssh -i ~/.crc/machines/crc/id_rsa core@192.168.130.11
df -h /sysroot
sudo xfs_growfs /sysroot
df -h /sysroot
```

And we are done.
