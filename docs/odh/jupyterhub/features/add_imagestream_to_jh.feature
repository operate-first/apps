@operations
Feature: A operations I need to provision a new ImageStream to JupyterHub on MOC

    Background:
        Given I am a user of MOC-ZERO
        * I have access to JupyteHub on MOC-ZERO

    Scenario: Add the imagestream to the operate-first/apps repo

        Given there exists an image quay.io/thoth-station/s2i-minimal-notebook

        When I update templates/imagestream-template.yaml with .metadata.annotations.opendatahub\.io/notebook-image-url = "https://github.com/thoth-station/s2i-minimal-notebook"
        * I update templates/imagestream-template.yaml with .metadata.annotations.opendatahub\.io/notebook-image-name = "Test minimal notebook Image"
        * I update templates/imagestream-template.yaml with .metadata.annotations.opendatahub\.io/notebook-image-desc = "Jupyter notebook image with minimal dependency set to start experimenting with Jupyter environment."
        * I update templates/imagestream-template.yaml with .metadata.name = test-s2i-minimal-notebook
        * I update templates/imagestream-template.yaml with .spec.tags[0].annotations.openshift\.io/imported-from = quay.io/thoth-station/s2i-minimal-notebook
        * I update templates/imagestream-template.yaml with .spec.tags[0].from.name = quay.io/thoth-station/s2i-minimal-notebook:v0.0.4
        * I update templates/imagestream-template.yaml with .spec.tags[0].name = v0.0.4
        * I add templates/imagestream-template.yaml to https://github.com/operate-first/apps/tree/master/odh/base/jupyterhub/notebook-images
        * I add templates/imagestream-template.yaml to https://github.com/operate-first/apps/blob/master/odh/base/jupyterhub/notebook-images/kustomization.yaml

        Then the image test-s2i-minimal-notebook should appear in JupyterHub Spawner UI
