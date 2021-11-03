@data-scientist
Feature: As data scientist I would like to access Jupyterhub on the MOC-ZERO cluster

    Scenario: Access JupyterHub on MOC-ZERO via MOC-SSO login

        Given I am a user of MOC-ZERO

        When I visit https://jupyterhub-opf-jupyterhub.apps.zero.massopen.cloud/hub/login?next=%2Fhub%2F
        * I login using Openshift MOC-SSO login

        Then I should be redirected to the JupyterHub Spawner Options
