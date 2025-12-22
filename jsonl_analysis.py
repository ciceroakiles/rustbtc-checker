import pprint
import pandas as pd

# Display all lines
#pd.set_option('display.max_rows', None)

# Display all columns
pd.set_option('display.max_columns', None)


def main():
    # Build sample dataframe
    filepath = "jsonl/base58ck.jsonl"
    df = pd.read_json(filepath, lines=True)

    # Show entire dataframe (column "level" hidden)
    #print("Dataframe for:", filepath[6:], "\n")
    print(df.drop('level', axis=1))


if __name__ == "__main__":
    main()
