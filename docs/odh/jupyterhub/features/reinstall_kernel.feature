@data-scientist
Feature: As data scientist I want to restart my Kernel to resolve miscellaneous errors

    Background:
        Given I am a user of MOC-ZERO
        * I have access to JupyteHub on MOC-ZERO
        * I have logged in to a Jupyter Notebook with a terminal open

    Scenario: Restart Kernel for Jupyter Notebook

        This scenario is based on [Issue 243](https://github.com/operate-first/support/issues/142#issuecomment-806220803).

        When I retrieve the KERNEL_TYPE and DISPLAY_NAME by running `jupyter kernelspec list --json`
        * I run command `ipython kernel install --user --name=${KERNELTYPE} --display-name '${DISPLAY_NAME}'`

        Then the Kernel is restored and ready to be started by JupyterHub again
