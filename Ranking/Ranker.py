from numpy import dot
from numpy.linalg import norm
from optparse import OptionParser
from sklearn.feature_extraction.text import CountVectorizer

stop_list = ""
vectorKeywordIndex = {}
tfKeywordIndex = {}

index_path="index.txt"

op = OptionParser()

op.add_option("-c", "--compare", action="store_true", dest="compare", help="Runs the comparation between the ranking")

op.add_option("-s","--search", dest="query_text",  
              help="The search query")

op.add_option("-r","--results", dest="total_of_results",  
              help="The total of returned results")

op.add_option("-f", "field-search", dest="field", default="", help = "Does the search based in the specified field")

argv = sys.argv[1:]
(opt, args) = op.parse_args(argv)



#Coloca na memoria o indice invertido e monta ele num dicionario pra achar mais facil
def boot_search_index(index_file):
    with open(index_file, "r") as index:
        offset = 0
        for line in index:
            word = line.split(",")[0] # pega so o primeiro campo, que corresponde a palavra
            global vectorKeywordIndex
            vectorKeywordIndex[word] = offset
            offset += 1

#Faz a busca
def ranked_search(query, documents):
    ratings = [(doc,cosine(to_vector(query), to_vector(doc))) for doc in documents]
    ratings.sort(key=lamba x : x[1], reverse=True) #sorting pelo rank
    return ratings

#Calcula o cosseno entre dois vetores
def cosine(vector1 , vector2):
    return float(dot(vector1,vector2)/(norm(vector1) * norm(vector2)))

#Transforma o documento pra vetor
def to_vector(document): #falta tf_idf
    vector = [0] * len(vectorKeywordIndex) 
    with open(document, "r") as doc:
        doc_content = doc.read() 
        word_list = remove_stopwords(doc_content)
        for word in word_list:s
            vector[vectorKeywordIndex[word]] = get_tf(word)
    return vector

#Pega o TF do indice invertido
def get_tf(word, doc): 
    with open(index_path, "r") as index:
        line = return_line(index, word)
        regex = doc + "\((.*?)\)"
        return re.findall(regex,line)[0][0]

#Retorna a linha que contem uma determinada palavra em um doc
def return_line(document, word)
    for line in document:
        if word in line
            return line    

#Bota na memoria a lista de stopwords - nao vai usar pra nada aparentemente
def build_stopword_list():
    with open("stopwords.txt", "r") as stp:
        global stop_list
        stop_list =  stp.read().lower().split()

#Remove as stopwords
def remove_stopwords(text):
    return [word for word in text.lower() if word not in stop_list]

def main():
    #build_stopword_list()
    boot_search_index(index_path)
    query = 'John Green'
    print(ranked_search(query))


if __name__ == '__main__':
    main()