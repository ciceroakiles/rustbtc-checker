# Tool

In this folder, we have the following scripts:

* `tool.sh`: Responsible for gathering user input.
* `json_parser.py`: This takes a tree and converts it to json lines.
* `json_filter.py`: Outputs less lines, according to what the user wants.

## Main menu

```
1) List available packages
2) Select package (selected: none)
3) View package tree
4) Publicly exposed items
5) Exit
> 
```

Items 3 and 4 are accessible after selecting a package. Below is the list of available packages, which can also be seen after choosing the first option.

<details>
<summary>List of available packages</summary>

```
bitcoin-addresses
base58ck
bitcoin-bip158
bitcoin
chacha20-poly1305
bitcoin-consensus-encoding
bitcoin-crypto
bitcoin-fuzz **
bitcoin_hashes
bitcoin-internals
bitcoin-io
bitcoin-p2p-messages
bitcoin-primitives
bitcoin-units
```

** = `cargo-modules` doesn't provide a tree for `bitcoin-fuzz` because this package has multiple targets.
</details>

<br/>

<details>
<summary>Tree view example</summary>

```
1) List available packages
2) Select package (selected: none)
3) View package tree
4) Publicly exposed items
5) Exit
> 2
Package name: base58ck
Package base58ck selected.

1) List available packages
2) Select package (selected: base58ck)
3) View package tree
4) Publicly exposed items
5) Exit
> 3
Processing package base58ck...

crate base58ck
├── trait Buffer: pub(crate)
├── fn decode: pub
├── fn decode_check: pub
├── fn encode: pub
├── fn encode_check: pub
├── fn encode_check_to_fmt: pub
├── fn encode_check_to_writer: pub(crate)
├── const fn encoded_check_reserve_len: pub(crate)
├── const fn encoded_reserve_len: pub(crate)
├── mod error: pub
│   ├── struct Error: pub
│   │   ├── fn incorrect_checksum: pub
│   │   ├── fn invalid_character: pub
│   │   └── fn invalid_length: pub
│   ├── enum ErrorInner: pub(crate)
│   ├── struct IncorrectChecksumError: pub(crate)
│   ├── struct InvalidCharacterError: pub
│   │   ├── fn invalid_character: pub
│   │   └── fn new: pub(crate)
│   ├── struct InvalidCharacterErrorInner: pub(crate)
│   └── struct TooShortError: pub(crate)
└── fn format_iter: pub(crate)

1) List available packages
2) Select package (selected: base58ck)
3) View package tree
4) Publicly exposed items
5) Exit
> 
```
</details>

## Publicly exposed items submenu

If the selected package is not "none", then it is possible to access this option.

```
1) List available packages
2) Select package (selected: specific-package)
3) View package tree
4) Publicly exposed items
5) Exit
> 4
Processing package specific-package...

Publicly exposed items:
1) All
2) enum/mod/struct
3) type/trait/fn/const_fn
4) error (x1 only)
5) error (x2 or more)
6) Line selection (1-N)
7) Back
> 
```

By default, this menu recognizes all lines from the package tree, so the size of `N` depends on the tree size.

<details>
<summary>Example with all lines shown (option 1 selected)</summary>

```
1) List available packages
2) Select package (selected: none)
3) View package tree
4) Publicly exposed items
5) Exit
> 2
Package name: base58ck
Package base58ck selected.

1) List available packages
2) Select package (selected: base58ck)
3) View package tree
4) Publicly exposed items
5) Exit
> 4
Processing package base58ck...

Publicly exposed items:
1) All
2) enum/mod/struct
3) type/trait/fn/const_fn
4) error (x1 only)
5) error (x2 or more)
6) Line selection (1-22)
7) Back
> 1

     1	{"type":"trait","name":"Buffer","path":"base58ck::Buffer"}
     2	{"type":"struct","name":"Error","path":"base58ck::error::Error"}
     3	{"type":"enum","name":"ErrorInner","path":"base58ck::error::ErrorInner"}
     4	{"type":"struct","name":"IncorrectChecksumError","path":"base58ck::error::IncorrectChecksumError"}
     5	{"type":"struct","name":"InvalidCharacterError","path":"base58ck::error::InvalidCharacterError"}
     6	{"type":"struct","name":"InvalidCharacterErrorInner","path":"base58ck::error::InvalidCharacterErrorInner"}
     7	{"type":"struct","name":"TooShortError","path":"base58ck::error::TooShortError"}
     8	{"type":"fn","name":"decode","path":"base58ck::decode"}
     9	{"type":"fn","name":"decode_check","path":"base58ck::decode_check"}
    10	{"type":"fn","name":"encode","path":"base58ck::encode"}
    11	{"type":"fn","name":"encode_check","path":"base58ck::encode_check"}
    12	{"type":"fn","name":"encode_check_to_fmt","path":"base58ck::encode_check_to_fmt"}
    13	{"type":"fn","name":"encode_check_to_writer","path":"base58ck::encode_check_to_writer"}
    14	{"type":"const_fn","name":"encoded_check_reserve_len","path":"base58ck::encoded_check_reserve_len"}
    15	{"type":"const_fn","name":"encoded_reserve_len","path":"base58ck::encoded_reserve_len"}
    16	{"type":"mod","name":"error","path":"base58ck::error"}
    17	{"type":"fn","name":"format_iter","path":"base58ck::format_iter"}
    18	{"type":"fn","name":"incorrect_checksum","path":"base58ck::error::Error::incorrect_checksum"}
    19	{"type":"fn","name":"invalid_character","path":"base58ck::error::InvalidCharacterError::invalid_character"}
    20	{"type":"fn","name":"invalid_character","path":"base58ck::error::Error::invalid_character"}
    21	{"type":"fn","name":"invalid_length","path":"base58ck::error::Error::invalid_length"}
    22	{"type":"fn","name":"new","path":"base58ck::error::InvalidCharacterError::new"}

Publicly exposed items:
1) All
2) enum/mod/struct
3) type/trait/fn/const_fn
4) error (x1 only)
5) error (x2 or more)
6) Line selection (1-22)
7) Back
> 
```
</details>
<br/>

You can choose items 2 to 5 depending on what you're looking for. This will change the maximum number of lines available for selection.

<details>
<summary>Example of filter applied: item 5 reduces output to 11 lines</summary>

```
Publicly exposed items:
1) All
2) enum/mod/struct
3) type/trait/fn/const_fn
4) error (x1 only)
5) error (x2 or more)
6) Line selection (1-22)
7) Back
> 5

     1	{"type":"struct","name":"Error","path":"base58ck::error::Error"}
     2	{"type":"enum","name":"ErrorInner","path":"base58ck::error::ErrorInner"}
     3	{"type":"struct","name":"IncorrectChecksumError","path":"base58ck::error::IncorrectChecksumError"}
     4	{"type":"struct","name":"InvalidCharacterError","path":"base58ck::error::InvalidCharacterError"}
     5	{"type":"struct","name":"InvalidCharacterErrorInner","path":"base58ck::error::InvalidCharacterErrorInner"}
     6	{"type":"struct","name":"TooShortError","path":"base58ck::error::TooShortError"}
     7	{"type":"fn","name":"incorrect_checksum","path":"base58ck::error::Error::incorrect_checksum"}
     8	{"type":"fn","name":"invalid_character","path":"base58ck::error::InvalidCharacterError::invalid_character"}
     9	{"type":"fn","name":"invalid_character","path":"base58ck::error::Error::invalid_character"}
    10	{"type":"fn","name":"invalid_length","path":"base58ck::error::Error::invalid_length"}
    11	{"type":"fn","name":"new","path":"base58ck::error::InvalidCharacterError::new"}

Publicly exposed items:
1) All
2) enum/mod/struct
3) type/trait/fn/const_fn
4) error (x1 only)
5) error (x2 or more)
6) Line selection (1-11)
7) Back
> 
```
</details>
<br/>

For item 6, "Line selection", this can be done for any line in range `1-N`.

<details>
<summary>Selection of line 7 from the previous example</summary>

```
Publicly exposed items:
1) All
2) enum/mod/struct
3) type/trait/fn/const_fn
4) error (x1 only)
5) error (x2 or more)
6) Line selection (1-11)
7) Back
> 6
Line number: 7

visible   type               name
    pub    mod              error
    pub struct              Error
    pub     fn incorrect_checksum

Publicly exposed items:
1) All
2) enum/mod/struct
3) type/trait/fn/const_fn
4) error (x1 only)
5) error (x2 or more)
6) Line selection (1-11)
7) Back
> 
```
</details>
