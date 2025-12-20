import pandas as pd

# Display all lines
#pd.set_option('display.max_rows', None)


def main():
    # Build dataframe
    filepath = "jsonl/rust-bitcoin-addresses-src-lib.rs.jsonl"
    df = pd.read_json(filepath, lines=True)
    df = df.sort_values(by='crate_id', ascending=True)

    # Show dataframe
    print("Dataframe for:", filepath[6:], "\n", df)


if __name__ == "__main__":
    main()
