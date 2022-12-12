# Development

## Getting access to OCP in for Development

Below is a list of methods you can get your own OCP 4.0+ environment for development/testing purposes:

## CRC

 * Setup CRC https://developers.redhat.com/products/codeready-containers/overview
   * Do not forget to install the corresponding version of `oc` tool or some commands might fail.

   * With the latest CRC, you can setup memory, CPU and disk side at the command line when starting CRC for the first time. E.g.:

   ```
    crc start -c 4 -d 64 -m 32768 -p  /home/big/crc-pull-secret.txt
   ```

   * You can also add [more disk space][1] to your existing CRC image.


## Quicklab

Note: Only applicable to Red Hat Employees

Follow the instructions [here][2] to set up your Quicklab environment.

[1]: crc-disk-size.md
[2]: setup_quicklab.md
