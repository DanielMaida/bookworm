from sklearn.datasets import load_files #summary
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB

def getStopwords():
    stopwords_string = ""
    with open("stopwords.txt", "r") as stp:
        stopwords_string = stp.read()
    return stopwords_string.split()

def main():
    #load subsets
    
    text_train_subset = load_files("dataset/")
    #text_test_subset = load_files("test/")   adicionar subset de teste 
    
    #initialize vectorizer
    count_vect = CountVectorizer()
    X_train = count_vect.fit_transform(text_train_subset.data)
    y_train = text_train_subset.target
    
    #Naive Bayes classifier
    classifier = MultinomialNB().fit(X_train, y_train)
    print("Training score: {0:.1f}%".format(
    classifier.score(X_train, y_train) * 100))
    
    

    
    

if __name__ == '__main__':
    main()