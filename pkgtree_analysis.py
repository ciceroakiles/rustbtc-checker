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


# Get parent levels
def get_parents(levels: list) -> list:
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


def main():
    pkgsdir = "package_trees"
    filename = "base58ck"

    # Open sample file
    lines = []
    with open(pkgsdir + "/" + filename + ".txt", 'r') as f:
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
        keys = ["level", "type", "name", "visible"]#, "parent"]
        values = [lvl, line[0][0], line[0][1], line[1], ""]
        data = dict(zip(keys, values))
        jsonline = json.dumps(data, separators=(',', ':'))
        jsonlines.append(jsonline)

    # Discover parent levels
    levels = list(reversed([get_level(line) for line in lines]))
    parentlines = get_parents(levels)

    # Get parent names
    parentnames = [""]
    for p in parentlines:
        parentnames.append(json.loads(jsonlines[p])['name'])

    # Update data
    for i, jsonl in enumerate(jsonlines):
        tmp = json.loads(jsonl)
        tmp["parent"] = parentnames[i]
        jsonlines[i] = json.dumps(tmp, separators=(',', ':'))

    for l in jsonlines:
        print(l)


if __name__ == "__main__":
    main()
