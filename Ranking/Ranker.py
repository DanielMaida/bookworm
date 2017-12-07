from numpy import dot
from numpy.linalg import norm
from optparse import OptionParser
from scipy.stats.stats import spearmanr

import os
import re
import math 
import sys

number_of_docs = 2410
docs_folder = "docs"
spearman_file = "spearman.txt"
vector_file = "vectors.txt"
vectorKeywordIndex = {}
doc_vectors = {}

#index_path="inverted_index_test.txt"
index_path="inverted_index_lower.txt"
#index_path="dummy_index.txt"

op = OptionParser()

op.add_option("-s", "--spearman", action="store_true", dest="spman", help="Runs the Spearman correlation between some predefined searches")

op.add_option("-q","--query", dest="query_text",  help="The search query" , default="")

op.add_option("-f","--fields", dest="search_fields",  help="The search fields in the format \"field,value\"", default="")

op.add_option("-t", "--tfidf", action="store_true", dest="tfidf_enabled", help="Enables the tfidf weight")

op.add_option("-v", "--boot_vector", action="store_true", dest="create_vectors", help="Creates the vectors")


argv = sys.argv[1:]
(opt, args) = op.parse_args(argv)

def create_vectors():
    global doc_vectors
    with open(index_path, "r") as idx:
        for line in idx: #para cada linha no indice invertido
            if line not in ['\n', '\r\n']: # se a linha nao for vazia
                docs_in_line = line.split(",")[1:] # pega os documentos junto com o tf
                word = line.split(',')[0] # pega a palavra
                prev = 0
                for doc in docs_in_line: # pra cada documento na linha
                    curr = int(doc.split("(")[0])
                    doc_idx = curr + prev # pega o id do documento
                    #print(curr, " ", "+", prev, " ", "=",doc_idx)
                    prev = doc_idx
                    tf_raw = re.findall(str(curr) + "\((.*?)\)",line)
                    if len(tf_raw) > 0:
                        word_tf = int(tf_raw[0])
                        if doc_idx not in doc_vectors: # se nao tiver esse doc no dicionario
                            doc_vectors[doc_idx] = [0] * len(vectorKeywordIndex)  #inicializa ele
                        if(opt.tfidf_enabled):
                            #insere o valor com peso tfidf daquela palavra na posicao dela no vetor correspondente a aquele doc
                            doc_vectors[doc_idx][vectorKeywordIndex[word]] = word_tf * get_idf(word)
                        else:
                            #insere o valor do tf daquela palavra na posicao dela no vetor correspondente a aquele doc
                            doc_vectors[doc_idx][vectorKeywordIndex[word]] = word_tf
    with open(vector_file, "w") as vf:
        for key, value in doc_vectors.items():
            vf.write(str(key) + ":")
            for item in value:
                vf.write(str(item) + ",")                        
            vf.write("\n")

def read_vectors():
    global doc_vectors
    with open(vector_file, "r") as vf:
        for line in vf:
            if line not in ['\n', '\r\n']:
                key = line.split(":")[0]
                values = line.split(":")[1].split(",")
                vector = [0] * len(vectorKeywordIndex)
                index = 0
                for val in values:
                    if val not in ['\n']:
                        vector[index] = int(val)
                        index += 1
            doc_vectors[key] = vector
    
#Coloca na memoria o indice invertido e monta ele num dicionario pra achar mais facil
def boot_search_index(index_file):
    with open(index_file, "r") as index:
        offset = 0
        for line in index:
            #if line not in ['\n', '\r\n']:
            word = line.split(",")[0]
            global vectorKeywordIndex
            vectorKeywordIndex[word] = offset
            offset += 1
            


#Faz a busca
def ranked_search(query):
    query_vector = query_to_vector(query)
    ratings = [(doc,cosine(query_vector, doc_vectors[doc])) for doc in doc_vectors]
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

#Pega o IDF do indice invertido 
def get_idf(word):
    with open(index_path, "r",encoding="utf-8", errors='ignore') as index:
        line = return_line(index,word)
        line = line[line.index(',') + 1:]
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
        if line not in ['\n', '\r\n']:
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
    if(opt.create_vectors):
        create_vectors()
    else:
        read_vectors()
    if(opt.spman):
        calculate_spearman(document_list)
    else:
        free_query = " ".join(["other." + word for word in opt.query_text.split()])
        field_query = "".join(opt.search_fields) 
        
        query = free_query + " " + field_query

        ranked_results = ranked_search(query)
        ranked_docs = [doc for doc,rank in ranked_results]
        #print("first query")
        #ranked_results = ranked_search(query)
        #ranked_docs = [doc for doc,rank in ranked_results]
        #print(ranked_docs)
        #print("second query")
        with open("queryResults.txt", "w") as res:
            for id in ranked_docs:
                res.write(str(id) + "\n")

if __name__ == '__main__':
    main()