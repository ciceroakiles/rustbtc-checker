import argparse
import pprint
import pandas as pd

# Display all lines
pd.set_option('display.max_rows', None)

# Display all columns
pd.set_option('display.max_columns', None)


def main(f: str):
    # Build sample dataframe
    df = pd.read_json("jsonl/" + f, lines=True)

    # Filter dataframe
    df = df[['type', 'name', 'path']].sort_values(by='name')

    # Export to another jsonl file
    df.to_json(
        path_or_buf='jsonl/output.jsonl',
        orient='records',
        lines=True
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Script that reads a jsonl file from "cargo-modules/jsonl" folder and prints a dataframe.'
    )
    parser.add_argument("-f", required=True, type=str, help="full name of the file")
    args = parser.parse_args()
    f = args.f
    main(f)
