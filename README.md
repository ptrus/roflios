# ROFL in Helios Deployment

This repository contains the deployment configuration for ROFL running in Helios at: https://ethrpc.rofl.cloud

## Verification

To verify and attest that the exact matching code is running inside the TEE, use the [Oasis CLI](https://github.com/oasisprotocol/cli):

```bash
oasis rofl build --verify --deployment test_peter
```

This command will build the project and verify that the deployment matches the code running in the Trusted Execution Environment.

Example output:
```
...
ROFL app built and bundle written to 'roflios.test_peter.orc'.
Computing enclave identity...
Built enclave identities MATCH latest manifest enclave identities.
Manifest enclave identities MATCH on-chain enclave identities.
```

## Running Your Own Instance

For a more general guide on how to run your own ROFL in Helios instance, see:
https://github.com/ptrus/rofl-helios
