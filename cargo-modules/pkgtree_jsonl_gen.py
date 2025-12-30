import argparse
import json
import string


# Returns the hierarchical level
def get_level(s: str) -> int:
    count = 0
    for char in s:
        if char.isalpha():
            break
        count += 1
    return int(count / 4)


# Cuts everything until the first alphabetic char occurrence
def cut_until_az(s: str) -> str:
    for i, char in enumerate(s):
        if char.isalpha():
            return s[i:]
    return ""


# Elaborate a parent list by levels
def discover_parents(levels: list) -> list:
    parents = []
    for i in range(len(levels)):
        for j in range(i+1, len(levels)):
            # Check for first occurrence of a lower level
            if levels[j] < levels[i]:
                parent = len(levels)-1-j
                #print(f"Line {len(levels)-1-i} - current level: {levels[i]} - parent line: {parent}")
                parents.append(parent)
                break
    return list(reversed(parents))


# Get a parent line
def get_parent(lines: list, line: str) -> str:
    parent = json.loads(line)["parent"]
    return lines[parent]


# Build a path until line name
def get_paths(lines: list, line: str) -> str:
    res = []

    # Begin with line name
    res.append(json.loads(line)["name"])

    # Get every parent until line 0 is reached
    while json.loads(line)["parent"] != 0:
        parent = get_parent(lines, line)
        res.append(json.loads(parent)["name"])
        line = parent

    # Insert line 0
    root = json.loads(lines[0])["name"]
    if root not in res:
        res.append(root)

    # Full string with Rust separator
    return '::'.join(list(reversed(res)))


def open_file(path: str) -> list:
    lines = []

    # Open file
    with open(path, 'r') as f:
        lines = f.readlines()

    jsonlines = []
    for i, line in enumerate(lines):
        # Remove line break at the end, fix "const fn" space
        line = line[:-1].replace("const fn", "const_fn")

        # Calculates hierarchy levels
        lvl = get_level(line)
        #print(i, lvl, line)

        # Process line data
        line = cut_until_az(line)
        line = line.split(": ")
        line[0] = line[0].split(" ")
        if len(line) == 1: line.insert(1, "default") # only for first line

        # Prepare dictionary structure and convert it to a json line
        keys = ["level", "type", "name", "visible"]
        values = [lvl, line[0][0], line[0][1], line[1], ""]
        data = dict(zip(keys, values))
        jsonline = json.dumps(data, separators=(',', ':'))
        jsonlines.append(jsonline)

    # Discover parent levels and parent lines
    levels = list(reversed([get_level(line) for line in lines]))
    parentlines = discover_parents(levels)

    # Insert a value for the first line
    parentlines.insert(0, 0)

    # Update data
    for i, jsonl in enumerate(jsonlines):
        tmp = json.loads(jsonl)

        # Add parent lines
        tmp["parent"] = parentlines[i]
        jsonlines[i] = json.dumps(tmp, separators=(',', ':'))

        # Add paths
        tmp["path"] = get_paths(jsonlines, jsonlines[i])
        jsonlines[i] = json.dumps(tmp, separators=(',', ':'))

    return jsonlines


def main(f: str):
    # Get json lines from a file
    jsonlines = open_file(f)

    for l in jsonlines:
        print(l)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Script that parses a txt file from "cargo-modules/package_trees" folder and outputs json lines.'
    )
    parser.add_argument("-f", required=True, type=str, help="full path of the file")
    args = parser.parse_args()
    f = args.f
    main(f)
