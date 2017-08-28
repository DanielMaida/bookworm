import io
from bs4 import BeautifulSoup

def parseHtml(html):
    soup = BeautifulSoup(html,"html.parser")
   
    for script in soup(["script","style"]):
        script.extract()
    
    raw_content = soup.get_text()
    return raw_content.encode('utf-8')

def tokenizer(html):
    stopwords = []
    with open("stopwords.txt", "r") as sw:
        stopwords = sw.read()
    stopwords = stopwords.split()
    page_content = parseHtml(html).split()
    resultwords  = [word for word in page_content if word.lower() not in stopwords and len(word) > 3 and word.isalnum()]
    result = ' '.join(resultwords)
    return result              

def main():
   
   html = io.open("teste.html", encoding="utf-8")
   html_content = tokenizer(html)
   bag_of_words = html_content.split()
   for word in bag_of_words:
     print(word)
   

if __name__ == '__main__':
   main()

    
