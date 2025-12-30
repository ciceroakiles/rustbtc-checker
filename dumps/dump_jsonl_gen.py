import argparse
import json


def open_file(path: str) -> list:
    lines = []

    # Open file
    with open(path, 'r') as f:
        lines = f.readlines()

    jsonlines = []
    for i, line in enumerate(lines):
        # Remove line break at the end
        line = line[:-1]

        # Remove everything after "(" and "<"
        line = line.split("(")[0]
        line = line.split("<")[0]

        # Remove "#[non_exhaustive]" occurrences
        line = line.split(" ")
        if line[0] == "#[non_exhaustive]": del line[0]

        # Name extraction
        name = line[2].split("::")[-1]

        # Prepare dictionary structure and convert it to a json line
        keys = ["type", "name", "path"]
        values = [line[1], name, line[2]]
        data = dict(zip(keys, values))
        jsonline = json.dumps(data, separators=(',', ':'))
        jsonlines.append(jsonline)

    return jsonlines


def main(f: str):
    # Get json lines from a file
    jsonlines = open_file(f)

    for l in jsonlines:
        print(l)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Script that parses a txt file from "cargo-modules/dumps" folder and outputs json lines.'
    )
    parser.add_argument("-f", required=True, type=str, help="full path of the file")
    args = parser.parse_args()
    f = args.f
    main(f)
