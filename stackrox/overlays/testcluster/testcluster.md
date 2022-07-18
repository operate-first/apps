# Test Cluster notes

## Persistent volume issues
From what I have read in the kustomize documentation their is no way to get rid of the persistent volume from the original kustomize file.
Instead what I am doing is copying the original yaml file and getting rid of anything to do with persistent volume. This is because due to
the limitations of the test cluster. The test cluster does not dynamically allocate persistent volumees which is needed for stackrox to store data
via a persistent volume claim. This should not matter in a production enviorment.

## Stackrox password issues

Right now I have to figure out a way to store the stackrox passwords somewhere else instead of it being placed in the yaml file. This is for security reasons and to pass the pre-commit tests.