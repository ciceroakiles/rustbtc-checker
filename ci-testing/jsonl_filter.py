import argparse
import pandas as pd

# Display all lines
pd.set_option('display.max_rows', None)

# Display all columns
pd.set_option('display.max_columns', None)


def get_line(l: int):
    # Temporary dataframe for main path finding
    tmpdf = pd.read_json('filtered_parsed_tree.jsonl', lines=True)
    tmpdf = tmpdf[['type', 'name', 'path']]
    tmpdf = tmpdf.loc[l-1]
    path = tmpdf['path']

    # Get paths for the queries
    s = path.count("::")
    allpaths = []
    for i in range(s):
        subpath = path.rsplit("::", i)[0]
        allpaths.insert(0, subpath)
    #print(allpaths)

    # Query paths
    df = pd.read_json('parsed_tree.jsonl', lines=True)
    df = df[df['path'].isin(allpaths)].sort_values(by='level')
    df = df[['visible', 'type', 'name']]

    # Output results
    with open('dataframe.txt', 'a') as f:
        f.write(df.to_string(header=True, index=False))


def main(f: str, t: int, l: int):
    # Build sample dataframe
    df = pd.read_json(f, lines=True)

    # Sort dataframe items by "name"
    df = df[['type', 'name', 'path']].sort_values(by='name')

    match t:
        case 1:
            # No changes
            pass
        case 2:
            # Filter for "enum/mod/struct" only
            df = df[(df['type'] == 'enum') | (df['type'] == 'mod') | (df['type'] == 'struct')]
        case 3:
            # Filter for "type/trait/fn/const_fn" only
            df = df[(df['type'] == 'type') | (df['type'] == 'trait') | (df['type'] == 'fn') | (df['type'] == 'const_fn')]
        case 4:
            # Filter for "error" only once on full path (lowercase comparison)
            mask = (df['path'].str.lower().str.count("error") == 1)
            df = df[mask]
        case 5:
            # Filter for "error" twice or more on full path (lowercase comparison)
            mask = (df['path'].str.lower().str.count("error") >= 2)
            df = df[mask]
        case 6:
            # Line inspection
            get_line(l)

    # Generate output
    df.to_json('filtered_parsed_tree.jsonl', orient='records', lines=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Script that reads and filters a jsonl file.'
    )
    parser.add_argument("-f", required=True, type=str, help="full name of the file")
    parser.add_argument("-t", required=True, type=int, help="filter type")
    parser.add_argument("-l", required=False, type=int, help="line number")
    args = parser.parse_args()
    main(args.f, args.t, args.l)
