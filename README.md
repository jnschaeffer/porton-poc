# porton-poc - Proof of concept API gateway + STS deployment

porton-poc contains a Docker Compose environment containing:

* [identity-manager-sts][identity-manager-sts], configured to accept JWTs from Equinix's OIDC provider
* [Portón][porton], configured to validate JWTs issued by identity-manager-sts
* [jwt-inspector][jwt-inspector], configured to inspect JWTs issued by identity-manager-sts

The goal of this repository and environment is to demonstrate an end-to-end flow from an external OIDC provider's tokens to a backend service that only accepts tokens from a single issuer.

[identity-manager-sts]: https://github.com/infratographer/identity-manager-sts/
[porton]: https://github.com/infratographer/porton/
[jwt-inspector]: https://github.com/jnschaeffer/jwt-inspector/

# Getting started

To start up porton-poc, just use Make. All services will be fetched from GitHub and built on demand. On the first run, a private key will be generated for identity-manager-sts.

```
$ make up
```

You can tear down the environment like so:

```
$ make down
```

Services are available on the host network at the following ports:

| Service              | Port |
|----------------------|------|
| identity-manager-sts | 8081 |
| Portón               | 8080 |
| jwt-inspector        | 8000 |

# Usage

Grab an access token from https://auth.equinix.com however works for you. Once you have done this, you can exchange it for a token issued by identity-manager-sts and pass that to the deployed Portón instance:

```
$ read -s AUTH_TOKEN # enter your token into the silent prompt
$ STS_TOKEN="$(curl -s --user my-client:foobar -XPOST -d "grant_type=urn:ietf:params:oauth:grant-type:token-exchange&subject_token=$AUTH_TOKEN&subject_token_type=urn:ietf:params:oauth:token-type:jwt&audience=foo" http://localhost:8081/token | jq -r .access_token)"
$ curl -s --oauth2-bearer "$STS_TOKEN" http://localhost:8080/user | jq
```

If everything worked, you should receive a JSON payload containing the claims of the token issued by identity-manager-sts.

You can also check the token against jwt-inspector directly for good measure:

```
$ curl -s --oauth2-bearer "$STS_TOKEN" http://localhost:8000/user | jq
```
