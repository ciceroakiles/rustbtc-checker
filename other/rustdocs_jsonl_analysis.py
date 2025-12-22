import pprint
import pandas as pd

# Display all lines
#pd.set_option('display.max_rows', None)


def main():
    # Build sample dataframe
    filepath = "jsonl/rust-bitcoin-addresses-src-lib.rs.jsonl"
    df = pd.read_json(filepath, lines=True)
    df = df.sort_values(by='crate_id', ascending=True).reset_index(drop=True)

    # Show entire dataframe
    #print("Dataframe for:", filepath[6:], "\n", df)

    # Show partial dataframe
    #print(df[["crate_id", "path"]])

    # Make a dictionary from dataframe
    framedict = df.groupby('crate_id')['path'].apply(list).to_dict()

    # Get crate names and remove the first item in the lists
    crates = []
    for key, value in framedict.items():
        crates.append(value[0][0])
        framedict[key] = [sublist[1:] for sublist in value]

    # Change dictionary keys and display crate structure
    newdict = {newkey: v for newkey, v in zip(crates, framedict.values())}
    pprint.pprint(newdict, indent=2)


if __name__ == "__main__":
    main()
