# Oxford-Hackathon Corruption Combat Coders

Welcome to the Decomm (decentralized e-commerice) project and to the internet computer development community.

To get started, you might want to explore the project directory structure and the default configuration file. Working with this project in your development environment will not affect any production deployment or identity tokens.

To learn more before you start working with back_end and front_end, see the following documentation available online:

- [Quick Start](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)
- [ckBTC and Bitcoin Integration](https://internetcomputer.org/docs/current/tutorials/developer-journey/level-4/4.3-ckbtc-and-bitcoin)
- [Svelte Front-End Framework](https://svelte.dev/)
- [Tailwind Styling System](https://tailwindcss.com/)
- [Shadcn-Svelte Component Library](https://www.shadcn-svelte.com/)


## The DFINITY Command-Line
____________________________________

This project utilizes The DFINITY command-line execution environment (dfx). The primary tool for creating, deploying, and managing, dapps that are developed in for the Internet Computer.


***Note that currently the dfx tool is not natively supported on windows.***

In order to use dfx on a Windows machine you'll need to download the Windows Subsystem for Linux (WSL). Refer to Microsoft's official guide [here](https://learn.microsoft.com/en-us/windows/wsl/install), and [here](https://learn.microsoft.com/en-us/windows/wsl/setup/environment)


### Installing IC SDK and DFX

To install dfx run the following:

```bash
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
```

To verify that the IC SDK is successfully installed, run the following command:
```bash
dfx --version
```

It's recommended to create an identity using dfx. To set an identity and a key run the following command:

```bash
dfx identity new
```

Learn more about dfx identities here - [dfx identity](https://internetcomputer.org/docs/current/references/cli-reference/dfx-identity)


## Starting the project

install the relevant packages needed to run the frontend for the first time by running:

```bash
npm install
```

--------------------------------------
If you want to start working on your project, run the following commands:

Open two separate terminals and in each terminal run:


```bash
# Terminal 1
cd /Oxford
npm run generate
npm run startdfx
```

```bash
# Terminal 2
npm run deploy
```

This will build and deploy the project locally.

## Running the project locally with Hot Module Replacement

If you want to test your project locally with Hot Module Replacement (HMR), you can use the following commands:

```bash
# Terminal 1
cd /Oxford
npm run generate
npm run startdfx
```

```bash
# Terminal 2
npm run deploy
npm run dev
```

Using svelte's native localhost:5173 local server you can now edit your code with HMR without the need to rebuild the files to see changes.

## Deploying to IC

To deploy to the internet computer run the following command:

```bash
npm run deployIC
```

or

```bash
dfx deploy --network ic backend && dfx deploy --network ic frontend
```

## Additional Commands
A list of all predefined commands can be found in the package.json file.

Here are some commands that might be useful:

To deposit cycles to a canister run:

```bash
npm run addCyclesIC <amount> <Canister ID>
```

To check the status of a canister run:

```bash
npm run canisterStatus <Canister ID>
```
To rebuild a canisters on the internet computer run:

```bash
npm run rebuildCanister <Canister ID>
```

To get the ID of a canister from the canister name run:

```bash
npm run canisterIDIC <Canister Name>
```


## Design Documents

Design documents such as architecture design, UI mokcups, and data designs can be found in the design documents folder in this repository. [View Design Documnets]()