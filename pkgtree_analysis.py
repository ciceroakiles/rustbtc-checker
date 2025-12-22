
def main():
    pkgsdir = "package_trees"

    # Open sample file
    with open(pkgsdir + "/bitcoin-consensus-encoding.txt", 'r') as file:
        for line in file:

            # Process lines
            line = line.replace("crate ", "")
            line = line.replace(":", "")
            line = line.replace("const fn", "constfn")
            print(f"{{{chr(34)}item{chr(34)}:{chr(34)}{line[:-1]}{chr(34)}}}")


if __name__ == "__main__":
    main()
