# Hemi Instructions

For compatibility with PoP-related changes to `op-geth`, Blockscout docker images must be built from source to operate correctly.

If you do not have Docker installed, install it first following a guide like [this one](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04).

Note that the default branch has been configured to connect to a local instance of op-geth after running the instructions to deploy a Hemi L2 network based on [the `infrastructure` repo](https://github.com/hemilabs/infrastructure) which sets up op-geth's HTTP RPC API (`--http.port`) on port 18546.

First clone this repo:

```sh
git clone https://github.com/hemilabs/blockscout
cd blockscout
```

Then run the docker containers with the `build` flag to compile the codebase before starting up the docker images:

```sh
cd docker-compose
docker-compose up --build
```

The build process takes 5-10 minutes the first time you run it.

Once the build is complete and the containers start up, you should be able to open a web browser and view the explorer by navigating to the IP/DNS of the server, for example `http://localhost:90`. It may take several minutes for blockscout to load on first initialization.

You should see the following containers running if you run `docker ps`:

```text
CONTAINER ID   IMAGE                                               COMMAND                  CREATED              STATUS                        PORTS                                                                                              NAMES
767b30ee43f4   nginx                                               "/docker-entrypoint.…"   About a minute ago   Up About a minute             0.0.0.0:90->90/tcp, :::90->90/tcp, 0.0.0.0:8090-8091->8090-8091/tcp, :::8090-8091->8090-8091/tcp   proxy
3029051483b6   ghcr.io/blockscout/stats:latest                     "./stats-server"         About a minute ago   Up About a minute                                                                                                                stats
4fb359138be5   hemilabs/frontend:main                              "./entrypoint.sh nod…"   About a minute ago   Up About a minute             3000/tcp                                                                                           frontend
762b238f229e   postgres:14                                         "docker-entrypoint.s…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:7433->5432/tcp, :::7433->5432/tcp                                                          stats-postgres
38650109bbde   hemilabs/blockscout:latest                          "sh -c 'bin/blocksco…"   About a minute ago   Up About a minute                                                                                                                backend
872336afa117   postgres:14                                         "docker-entrypoint.s…"   About a minute ago   Up About a minute (healthy)   0.0.0.0:7432->5432/tcp, :::7432->5432/tcp                                                          db
f219e08c1004   ghcr.io/blockscout/visualizer:latest                "./visualizer-server"    About a minute ago   Up About a minute                                                                                                                visualizer
f8a2d95be7d8   redis:alpine                                        "docker-entrypoint.s…"   About a minute ago   Up About a minute             6379/tcp                                                                                           redis_db
7e5747691b8c   ghcr.io/blockscout/sig-provider:latest              "./sig-provider-serv…"   About a minute ago   Up About a minute                                                                                                                sig-provider
```

## Known Issues w/ Hemi

1. The "Contract" tab for smart contract addresses does not appear, at least for addresses holding smart contracts deployed as part of the genesis configuration.

2. Even after indexing the chain, CPU usage remains high (primarily from `beam.smp`). This may be a configuration issue?

3. ~~The explorer does not detect the chain is a rollup and so does not display L1->L2 deposits or L2->L1 withdrawals in their own list. Rollups likely need additional configuration (and possibly a connection to a regular geth node?).~~

<h1 align="center">Blockscout</h1>
<p align="center">Blockchain Explorer for inspecting and analyzing EVM Chains.</p>
<div align="center">

[![Blockscout](https://github.com/blockscout/blockscout/workflows/Blockscout/badge.svg?branch=master)](https://github.com/blockscout/blockscout/actions)
[![](https://dcbadge.vercel.app/api/server/blockscout?style=flat)](https://discord.gg/blockscout)

</div>


Blockscout provides a comprehensive, easy-to-use interface for users to view, confirm, and inspect transactions on EVM (Ethereum Virtual Machine) blockchains. This includes Ethereum Mainnet, Ethereum Classic, Optimism, Gnosis Chain and many other **Ethereum testnets, private networks, L2s and sidechains**.

See our [project documentation](https://docs.blockscout.com/) for detailed information and setup instructions.

For questions, comments and feature requests see the [discussions section](https://github.com/blockscout/blockscout/discussions) or via [Discord](https://discord.com/invite/blockscout).

## About Blockscout

Blockscout allows users to search transactions, view accounts and balances, verify and interact with smart contracts and view and interact with applications on the Ethereum network including many forks, sidechains, L2s and testnets.

Blockscout is an open-source alternative to centralized, closed source block explorers such as Etherscan, Etherchain and others.  As Ethereum sidechains and L2s continue to proliferate in both private and public settings, transparent, open-source tools are needed to analyze and validate all transactions.

## Supported Projects

Blockscout currently supports several hundred chains and rollups throughout the greater blockchain ecosystem. Ethereum, Cosmos, Polkadot, Avalanche, Near and many others include Blockscout integrations. [A comprehensive list is available here](https://docs.blockscout.com/about/projects). If your project is not listed, please submit a PR or [contact the team in Discord](https://discord.com/invite/blockscout).

## Getting Started

See the [project documentation](https://docs.blockscout.com/) for instructions:

- [Manual deployment](https://docs.blockscout.com/for-developers/deployment/manual-deployment-guide)
- [Docker-compose deployment](https://docs.blockscout.com/for-developers/deployment/docker-compose-deployment)
- [Kubernetes deployment](https://docs.blockscout.com/for-developers/deployment/kubernetes-deployment)
- [Manual deployment (backend + old UI)](https://docs.blockscout.com/for-developers/deployment/manual-old-ui)
- [Ansible deployment](https://docs.blockscout.com/for-developers/ansible-deployment)
- [ENV variables](https://docs.blockscout.com/for-developers/information-and-settings/env-variables)
- [Configuration options](https://docs.blockscout.com/for-developers/configuration-options)

## Acknowledgements

We would like to thank the [EthPrize foundation](http://ethprize.io/) for their funding support.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution and pull request protocol. We expect contributors to follow our [code of conduct](CODE_OF_CONDUCT.md) when submitting code or comments.

## License

[![License: GPL v3.0](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
