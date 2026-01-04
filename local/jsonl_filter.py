import argparse
import pandas as pd

# Display all lines
pd.set_option('display.max_rows', None)

# Display all columns
pd.set_option('display.max_columns', None)


def main(f: str, t: int):
    # Build sample dataframe
    df = pd.read_json(f, lines=True)

    # Sort dataframe
    df = df[['type', 'name', 'path']].sort_values(by='name')

    if t == 1:
        # Filter for "enum/mod/struct" only
        df = df[(df['type'] == 'enum') | (df['type'] == 'mod') | (df['type'] == 'struct')]
    elif t == 2:
        # Filter for "type/trait/fn/const_fn" only
        df = df[(df['type'] == 'type') | (df['type'] == 'trait') | (df['type'] == 'fn') | (df['type'] == 'const_fn')]

    # Generate output
    df.to_json('filtered_parsed_tree.jsonl', orient='records', lines=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Script that reads and filters a jsonl file.'
    )
    parser.add_argument("-f", required=True, type=str, help="full name of the file")
    parser.add_argument("-t", required=True, type=int, help="filter type")
    args = parser.parse_args()
    main(args.f, args.t)
