# rustbtc-checker

This repository is a small proof of concept tool which has two main goals:

- [x] Show publicly exposed components (e.g.: types, traits, etc)
- [ ] Provide simple verification against the project's policy rules

## Requirements

* A Linux machine with Python 3 and Rust installed
* A clone of the `rust-bitcoin` project
* `cargo-modules` installed

If you only have the first one, then running `setup.sh` will provide the remaining items.

The tool can still help if you want to use it to check other Rust projects aside from `rust-bitcoin`, but have in mind that you will need to make the necessary adjustments for it to work properly.

This was not tested on Mac and Windows environments, so if you still plan on use it in any of those, then use it at your own risk.

## How it works

When running `cargo-modules` inside the `rust-bitcoin` project folder and passing a specific package as an argument, like:

<code>cargo-modules structure --package specific-package</code>

We get something that looks like the following output:

```
crate specific-package
├── type type_name: pub(crate)
├── trait trait_name: pub
├── fn function1: pub
├── const fn function2: pub(crate)
└── mod module_error: pub
    ├── struct Error: pub
    │   ├── fn function3: pub(super)
    │   └── fn function4: pub
    └── enum ErrorInner: pub(self)
```

This type of tree view is great in terms of being human readable, but it's not machine readable yet. That's where the parsing process comes in.

The `tool.sh` script, provided in the `tool` folder with other scripts, is capable of parsing the tree and provide a machine readable version of the previous tree in json lines format:

```
{"type":"type","name":"type_name","path":"specific-package::type_name"}
{"type":"trait","name":"trait_name","path":"specific-package::trait_name"}
{"type":"fn","name":"function1","path":"specific-package::function1"}
{"type":"const_fn","name":"function2","path":"specific-package::function2"}
{"type":"mod","name":"module_error","path":"specific-package::module_error"}
{"type":"struct","name":"Error","path":"specific-package::module_error::Error"}
{"type":"fn","name":"function3","path":"specific-package::module_error::Error::function3"}
{"type":"fn","name":"function4","path":"specific-package::module_error::Error::function4"}
{"type":"enum","name":"ErrorInner","path":"specific-package::module_error::ErrorInner"}
```

This can be done for any package inside the project, as long as it can provide a tree like `specific-package`'s.

## Project structure

This project has several folders:

* `tool`: This is where `tool.sh` and some other python scripts are located, needs further interaction and provides custom options. Can be run at any time, and also generates some temporary files for inspection during its execution.
* `ci-testing`: The scripts in here are intended to only generate outputs, that is, to run without any user interaction.
* `dumps`: Contains some output files for comparison purposes and further analysis.
* `other`: Has scripts that deal with rustdocs (discontinued, but will remain there if you want to look around anyways).
