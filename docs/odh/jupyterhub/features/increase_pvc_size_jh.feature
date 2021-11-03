@data-scientist
Feature: As data scientist I want to increase size of a PVC in JupyterHub

    Background:
        Given I am a user of MOC-ZERO
        * I have access to JupyteHub on MOC-ZERO

    Scenario: Request PVC size to be updated/enlarged

        This scenario is based on [Issue 243](https://github.com/operate-first/support/issues/86).

        When I open a an issue at [operate-first/support](https://github.com/operate-first/support) using https://github.com/operate-first/support/issues/new?assignees=&labels=user-support&template=pvc_request.md&title= template
        * The issue is resolved by the Ops team

        Then My PVC resource for JupyterHub is updated to DESIRED_SIZE

@operations
Feature: As operations I want to increase size of a PVC in JupyterHub

    Background:
        Given I am a user of MOC-ZERO
        * I have access to manage JupyteHub on MOC-ZERO
        * User (Requester) requested expansion of a PVC in [operate-first/support/](https://github.com/operate-first/support/)
        * Requester is an user of MOC-ZERO
        * Requester has access to JupyteHub on MOC-ZERO

    Scenario: Requester uses the default PVC

        This scenario is based on [PR243](https://github.com/operate-first/apps/pull/243) pull request.

        Given Requester has no custom PVC resource for JupyteHub

        When I update the templates/pvc-template.yaml with .metadata.annotations.hub\.jupyter\.org/username = Requestor's username
        * I update the templates/pvc-template.yaml with .metadata.name = jupyterhub-nb-URLENCODED_USERNAME-pvc
        * I update the templates/pvc-template.yaml with .spec.resources.requests.storage = DESIRED_SIZE
        * I encrypt the resource with SOPS
        * I add the PVC resource to https://github.com/operate-first/apps/tree/master/odh/overlays/moc/jupyterhub/pvcs/user-USERNAME-pvc.enc.yaml
        * I list the resource at https://github.com/operate-first/apps/tree/master/odh/overlays/moc/jupyterhub/pvcs/secret-generator.yaml
        * I commit the updated file and open a PR
        * PR is merged and changes applied by ArgoCD
        * I restart requester's JupyterHub server

        Then Requester's PVC resource for JupyterHub is updated to DESIRED_SIZE

    Scenario: Requester already has a custom PVC defined
        Given Requester has a custom PVC resource for JupyteHub declared at https://github.com/operate-first/apps/tree/master/odh/overlays/moc/jupyterhub/pvcs/user-USERNAME-pvc.enc.yaml

        When I fetch my PVC resource from https://github.com/operate-first/apps/tree/master/odh/overlays/moc/jupyterhub/pvcs/user-USERNAME-pvc.enc.yaml
        * I update the resource via SOPS with .spec.resources.requests.storage = DESIRED_SIZE
        * I commit the updated file and open a PR
        * PR is merged and changes applied by ArgoCD
        * I restart requester's JupyterHub server

        Then Requester's PVC resource for JupyterHub is updated to DESIRED_SIZE
