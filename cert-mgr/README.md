# Installing Cert Manager

1. Install the Cert-Manager helm chart (with CRDs included)

```
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.0.3 \
  --set installCRDs=true
```

2. Verify installation

> kubectl get pods --n cert-manager

# Test Self-Sign cert

> kubectl apply -f ./self-signed-test.yml

Find the certs using > `kubectl -n cert-manager-test get certificates`

# Issuers

## DNS01 Certificate Issuer (Route53)

1. Generate credentials (secret access key) + store them in `./credentials.env` to manage a Route53 zone using the following IAM permissions:

```
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Sid": "VisualEditor0",
   "Effect": "Allow",
   "Action": [
    "route53:GetChange",
    "route53:ChangeResourceRecordSets",
    "route53:ListResourceRecordSets"
   ],
   "Resource": [
    "arn:aws:route53:::hostedzone/Z06420923OIIZF6U0R3GQ",
    "arn:aws:route53:::change/*"
   ]
  },
  {
   "Sid": "VisualEditor1",
   "Effect": "Allow",
   "Action": "route53:ListHostedZonesByName",
   "Resource": "*"
  }
 ]
}
```

2. Store the credentials as a secret

> kubectl -n cert-manager create secret generic acme-route53 --from-env-file=./credentials.env

3. Update the DNS issuer's access key `./issuer-dns01.yml` and the apply

> kubectl -n cert-manager apply -f ./issuer-dns01.yml

4. Then use the Certificate CRD to ask for new certs in other Namespaces

> kubectl apply -f ./test-cert.yml

1. Validate the cert was successful

> kubectl get certificates

### References

- https://medium.com/@karan.brar/configure-letsencrypt-and-cert-manager-with-kubernetes-3156981960d9
