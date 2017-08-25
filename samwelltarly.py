import io
from bs4 import BeautifulSoup

def parseHtml(html):
    soup = BeautifulSoup(html,"html.parser")
   
    for script in soup(["script","style"]):
        script.extract()
    
    raw_content = soup.get_text()
    return raw_content

def tokenizer(html):
    stopwords = []
    with open("stopwords.txt", "r") as sw:
        stopwords = sw.readlines()
    page_content = parseHtml(html)
    return page_content              

def main():
   html = io.open("teste.html", encoding="utf-8")
   html_content = parseHtml(html)
   bag_of_words = html_content.split()
   print(bag_of_words)
   

if __name__ == '__main__':
   main()

    
