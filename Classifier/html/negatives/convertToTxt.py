from bs4 import BeautifulSoup as bs
from nltk.stem.snowball import SnowballStemmer
import glob as g

stemmer = SnowballStemmer("portuguese")

def parseHTMLPage(html):
    soup = bs(html,'html.parser')
    for script in soup(["script","style"]):
        script.extract()
    raw_content = soup.getText().lower()
    
    return stemmer.stem(raw_content)

def main():
    files = g.glob("*.html")
    counter = 1
    for file in files:
        with open(file, mode='r', encoding="utf-8", errors='ignore') as f1:
            raw_content = parseHTMLPage(f1)
            name = "negative" + str(counter) + ".txt"
            with open(name, mode='w') as f2:
                f2.write(raw_content)
        counter += 1
    print("Done converting all files...")

if __name__ == '__main__':
    main()