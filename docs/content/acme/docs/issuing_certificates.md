# Issuing certificates

## Securing OpenShift `Route`s with ACME (Let's Encrypt)

We manage and deploy cluster wide deployment of [OpenShift ACME][1] controller. This operator facilitates [Let's Encrypt][2] certificate provisioning in any `namespace` on the cluster. Any `route` resource is eligible, please use the following annotation to mark the route as managed by this operator:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  annotations:
    kubernetes.io/tls-acme: "true"
```

Annotating a route will result with an additional temporary route and 2 pods being created in your `namespace`. Once the certificate is issued these pods will be removed. This process is repeated to renew certificates later on.

> Note: Keep in mind that ACME controller requests a new certificate for each Route object. Therefore if you expose multiple routes with the same domain host, a new certificate is created for each. This may lead to rate-limiting certificate issues. Letsencrypt has a strict limit of 5 requests per week for the same domain. If you need more, consider using Cert Manager.

## Issuing certificates via Cert Manager

For other workloads that rely on SSL/TLS certificates, you can also provision certificates via Cert Manager.

Please deploy following resources in your project:

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: ops-team@operate-first.cloud
    privateKeySecretRef:
      name: letsencrypt-key
    server: 'https://acme-v02.api.letsencrypt.org/directory'
    solvers:
      - http01:
          ingress:
            serviceType: ClusterIP
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ssl-certificate
spec:
  dnsNames:
    - <DOMAIN_HOST>
  issuerRef:
    name: letsencrypt
  secretName: <DESIRED_TLS_SECRET_NAME>
```

Once the certificate is issued, it can be found as a `Secret` resource in your namespace matching the name in `.spec.secretName` in the `Certificate` resource.

We currently support `http01` challenge only on `operate-first.cloud` dns. Supporting `dns01` challenge would require us to share DNS service account publicly and we don't want that. We can support that per request.

Further information about the Cert Manager can be found in the [upstream documentation](https://cert-manager.io/docs/).

[1]: https://github.com/tnozicka/openshift-acme
[2]: https://letsencrypt.org/
[3]: https://cert-manager.io/docs/
