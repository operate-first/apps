@data-scientist
Feature: As data scientist I want to know how much JupyterHub local storage (PVC) I have

    Background:
        Given I am a user of MOC-ZERO
        * I have access to JupyteHub on MOC-ZERO

    Scenario: Assess storage via Grafana dashboard

        When I visit https://grafana-route-opf-monitoring.apps.zero.massopen.cloud/d/24cc5f554da78f3ca60a40f190f7e23203f7d847/jupyterhub-usage?orgId=1
        * I select "User ID" and pick my OCP user name

        Then the amount of free storage in my pvc can be assessed by inspecting the used/total space panel.

    Scenario: Assess storage via Jupyterhub

        When I visit https://jupyterhub-opf-jupyterhub.apps.zero.massopen.cloud
        * I login using Openshift MOC-SSO login
        * I spawn a notebook image with: name s2i-minimal-notebook:v0.0.7, container size small, gpu count 0
        * I wait for notebook server to start
        * I click "new" and click "terminal"
        * I type `df -h` in the new terminal

        Then the amount of free storage in my pvc should be listed under "Available" column, mounted on /opt/app-root/src

@data-scientist
Feature: As data scientist I want to know what is consuming most of the space on my PVC

    Background:
        Given I am a user of MOC-ZERO
        * I have access to JupyteHub on MOC-ZERO

    Scenario: Check used storage on my PVC

        When I visit https://jupyterhub-opf-jupyterhub.apps.zero.massopen.cloud
        * I login using Openshift MOC-SSO login
        * I spawn a notebook image with: name s2i-minimal-notebook:v0.0.7, container size small, gpu count 0
        * I wait for notebook server to start
        * I click "new" and click "terminal"
        * Type `du -h --max-depth=2 . | sort -h` in the terminal

        Then I have a list of folders on my PVC sorted by their size

    Scenario: Cleanup Pipenv cache
        Given I have checked used storage on my PVC

        When Folder named `.cache/pipenv` consumes most of the space of given PVC

        Then I can delete `.cache/pipenv` folder to free the PVC
