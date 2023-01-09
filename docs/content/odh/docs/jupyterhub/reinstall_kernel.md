# How to restart a Notebook Kernel

A number of miscellaneous errors can be resolved by just restarting the kernel.

You can do this by running the following commands:

```bash
# retrieve the KERNEL_TYPE and DISPLAY_NAME by running
$ jupyter kernelspec list --json

# once these values are retrieved, run the following command, assign the env vars accordingly:
$ ipython kernel install --user --name=${KERNELTYPE} --display-name '${DISPLAY_NAME}'
```

Your kernel should then be restored and ready to be started by JupyterHub again.
