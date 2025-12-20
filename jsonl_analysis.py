import pandas as pd

#pd.set_option('display.max_rows', None)


def main():
    filepath = "jsonl/rust-bitcoin-addresses-src-lib.rs.jsonl"
    df = pd.read_json(filepath, lines=True)
    df = df.sort_values(by='crate_id', ascending=True)
    print(df)


if __name__ == "__main__":
    main()
