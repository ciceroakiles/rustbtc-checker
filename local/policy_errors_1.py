import argparse
import pandas as pd

PUBLIC_API_FILE = 'cargopubapi.txt'


def main(f: str):
    # Get jsonl entries
    df = pd.read_json(f, lines=True)
    jsonl_entries = df["path"].tolist()

    # Rebuild path
    path = f.split("/")
    path[-1] = PUBLIC_API_FILE
    path = '/'.join(path)

    # Get public api entries
    pubapi = []
    with open(path, 'r') as fl2:
        pubapi = fl2.readlines()

    # Check items
    matches = []
    for entry in jsonl_entries:
        group = []
        for l in pubapi:
            if entry in l:
                group.append(l)
        matches.append(group)

    # Print results
    res_dict = dict(zip(jsonl_entries, matches))
    for k, v in res_dict.items():
        # Current item  being checked
        print(k, "versus public api...")

        # List mismatches
        print(len(v), "mismatches")
        for value in v:
            print(value, end="")
        print("----")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Script that compares filtered_parsed_tree.jsonl against public api.'
    )
    parser.add_argument("-f", required=True, type=str, help="full path of the file")
    args = parser.parse_args()
    f = args.f
    main(f)
