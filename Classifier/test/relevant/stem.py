from nltk.stem.snowball import SnowballStemmer
import glob as g

stemmer = SnowballStemmer("portuguese")

def main():
    files = g.glob("*.txt")
    counter = 1
    for file in files:
        with open(file, mode='r', encoding="utf-8", errors='ignore') as f1:
            name = "test" + str(counter) + ".txt"
            with open(name, mode='w') as f2:
                f2.write(stemmer.stem(f1.read()))
        counter += 1

if __name__ == '__main__':
    main()