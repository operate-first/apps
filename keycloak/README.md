# Authenticate OpenShift Clusters

Deploy Keycloak as a centralized platform for authentication of OpenShift clusters

Each cluster is assigned a `KeycloakClient` that maps to _operate-first_ `KeycloakRealm`. This realm then sources GitHub as an identity provider and forwards the identity back to the Keycloak client (OpenShift cluster).
