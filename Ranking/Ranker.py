from numpy import dot
from numpy.linalg import norm
from optparse import OptionParser
from scipy.stats.stats import spearmanr

import os
import re
import math 
import sys

number_of_docs = 2411
docs_folder = "docs"
spearman_file = "spearman.txt"
vectorKeywordIndex = {}
tfKeywordIndex = {}

index_path="index.txt"

op = OptionParser()

op.add_option("-s", "--spearman", action="store_true", dest="spman", help="Runs the Spearman correlation between some predefined searches")

op.add_option("-q","--query", dest="query_text",  help="The search query")

op.add_option("-f","--fields", dest="search_fields",  help="The search fields in the format \"field,value\"")

op.add_option("-t", "--tfidf", action="store_true", dest="tfidf_enabled", help="Enables the tfidf weight")


argv = sys.argv[1:]
(opt, args) = op.parse_args(argv)

#Coloca na memoria o indice invertido e monta ele num dicionario pra achar mais facil
def boot_search_index(index_file):
    with open(index_file, "r") as index:
        offset = 0
        for line in index:
            if line not in ['\n', '\r\n']:
                word = line.split(",")[0].split(".")[1]
                global vectorKeywordIndex
                vectorKeywordIndex[word] = offset
                offset += 1



#Faz a busca
def ranked_search(query, documents):
    ratings = [(doc,cosine(query_to_vector(query), doc_to_vector(doc))) for doc in documents]
    ratings.sort(key=(lambda x: x[1]), reverse=True) #sorting pelo rank
    return ratings

#Calcula o cosseno entre dois vetores
def cosine(vector1 , vector2):
    dot_prod = dot(vector1,vector2)
    vec_norm = norm(vector1) * norm(vector2)
    if((vec_norm <= 0 ) or (dot_prod <= 0)):
        return 0
    else:
        return float(dot_prod/vec_norm)
    
#Transforma a query em um vetor para o calculo do cosseno
def query_to_vector(query):
    vector = [0] * len(vectorKeywordIndex) 
    word_list = query.lower().split()
    for word in word_list:
        if word in vectorKeywordIndex:
            vector[vectorKeywordIndex[word]] += 1
    return vector


#Transforma o documento pra vetor para o calculo do cosseno
def doc_to_vector(document): 
    vector = [0] * len(vectorKeywordIndex) 
    with open(document, "r") as doc:
        word_list = doc.read().lower().split()
        for word in word_list:
            if word in vectorKeywordIndex:
                if(opt.tfidf_enabled):
                    vector[vectorKeywordIndex[word]] = get_tf(word,document) * get_idf(word)
                else:
                    vector[vectorKeywordIndex[word]] = get_tf(word,document)
    return vector

#Pega o TF do indice invertido
def get_tf(word, doc): 
    with open(index_path, "r") as index:
        line = return_line(index, word)
        regex = doc.split(".")[0].split("/")[1] + "\((.*?)\)"
        tf = re.findall(regex,line)[0]
        return float(tf)

#Pega o IDF do indice invertido 
def get_idf(word):
    with open(index_path, "r") as index:
        line = return_line(index,word)
        regex = "\((.*?)\)"
        count = re.findall(regex,line)
        aux = 0
        for item in count:
            aux += float(item)
        idf = math.log
        return float(math.log(number_of_docs/1 + aux))


#Retorna a linha que contem uma determinada palavra em um doc
def return_line(document, word):
    for line in document:
        if word in line:
            return line    

def calculate_spearman(doclist):
    i = 1
    with open(spearman_file, "r") as spm:
        for line in spm.read().split():
            query = line.split(",")[0]
            ideal_rank = line.split(",")[1:]
            ranked_results = ranked_search(query,document_list)
            ranked_docs = [doc for doc,rank in ranked_results]
            print("Spearman Correlation ",i,": ", spearmanr(ranked_docs,ideal_rank))
            i += 1 

def main():
    boot_search_index(index_path)
    document_list = []
    for dirct, subdir, files in os.walk(docs_folder):
        for f in files:
            document_list.append(os.path.join(dirct,f)) 
    if(opt.spman):
        calculate_spearman(document_list)
    else:
        #free_query = " ".join(["other." + word for word in opt.query_text.split()])
        #field_query = "".join(opt.search_fields) 
        
        #query = free_query + " " + field_query

        #print(query)

        query = opt.query_text

        ranked_results = ranked_search(query,document_list)
        ranked_docs = [doc for doc,rank in ranked_results]
        print(ranked_docs)

if __name__ == '__main__':
    main()