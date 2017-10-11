#Code made by Daniel Maida {dfm2 (at) cin.ufpe.br}

#Util libraries
from sklearn import metrics
from optparse import OptionParser
from time import time
from bs4 import BeautifulSoup as bs
import sys

#Data loading and vectorizer libraries
from sklearn.datasets import load_files
from sklearn.feature_extraction.text import CountVectorizer

#Classifiers libraries
from sklearn.naive_bayes import GaussianNB
from sklearn.neural_network import MLPClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import LinearSVC

names = [
    "Gaussian Naive Bayes",  #0
    "Decision Tree",         #1
    "Linear SVC (SVM)",      #2
    "Logistic Regression",   #3
    "Multi Layer Perceptron" #4
]

classifiers = [
    GaussianNB(),
    DecisionTreeClassifier(max_depth=5),
    LinearSVC(),
    LogisticRegression(),
    MLPClassifier(solver='lbfgs', alpha=1e-5,
                    hidden_layer_sizes=(5, 2), random_state=1)
]



op = OptionParser()

op.add_option("-c","--classifier", dest="chosen_classifier", default="naivebayes", 
              help="The classifier name, it can be: \"naive_bayes\", \"dectree\", \"svm\", \"logreg\" or \"mlp\".")

op.add_option("--stemming", action="store_true",dest="stemming_enabled",
             help="Applies stemming in the dataset")

op.add_option("--html", action="store_true",dest="html_mode",
             help="Reads html files")

op.add_option("--benchmark", action="store_true", dest="is_benchmark",
              help="Run the tool in the benchmarking mode")

op.add_option("-f", "--filename", dest="filename",
              help ="The file path for the file you want to classify")

argv = sys.argv[1:]
(opt, args) = op.parse_args(argv)



def main():
    
    #load subsets
    train_subset = None
    test_subset = None
    if not opt.stemming_enabled:
        train_subset = load_files("dataset/")
        test_subset = load_files("test/")
    else:
        train_subset = load_files("stemdata/")
        test_subset = load_files("stemtest/")   

    
    if opt.is_benchmark:
        runBenchmark(train_subset,test_subset)
    else:
        #print data from test subsets
        print("Data subset information:")
        print(3*' ', "%d documents (training set)" % (len(train_subset.data)))
        print(3*' ', "%d documents  (test set)" % (len(test_subset.data)))
        print("\n")

        #initialize vectorizer
        vectorizer =  CountVectorizer(stop_words=getStopwords())
        X_train = vectorizer.fit_transform(train_subset.data).todense()
        y_train = train_subset.target
        
        classifier = None
        if opt.chosen_classifier == "naive_bayes":
            classifier = classifiers[0]
        elif opt.chosen_classifier == "dectree":
            classifier = classifiers[1]
        elif opt.chosen_classifier == "svm":
            classifier = classifiers[2]
        elif opt.chosen_classifier == "logreg":
            classifier = classifiers[3]
        elif opt.chosen_classifier == "mlp":
            classifier = classifiers[4]
        else:
            print("Invalid classifier chosen, using naive bayes, please use the --help command to see the valid classifiers\n")
            classifier = classifiers[0]

        classifier = classifier.fit(X_train, y_train)
        
        with open(opt.filename, mode='r', encoding="utf-8", errors='ignore') as input_data:
            input_text = ""
            if opt.html_mode:
                input_text = parseHTMLPage(input_data)
            else:
                input_text = input_data.read()    
            dt = vectorizer.transform([input_text])
            predict = classifier.predict(dt.toarray())
            print("Is relevant?", predict)
            return predict
        
def runBenchmark(train_subset,test_subset):
    
    print("Initializing vectorizer...")
    t0 = time()
    
    vectorizer = CountVectorizer(stop_words=getStopwords())
    X_train = vectorizer.fit_transform(train_subset.data).todense()
    y_train = train_subset.target
    
    duration = time() - t0
    print("done in %fs " % (duration))

    for name, clf in zip(names,classifiers):
        print(name," classifier:")
        
        t0 = time()
        clf.fit(X_train,y_train)
        duration = time() - t0
        print("Trained in %fs " % (duration))
        
        print(4*" ","Training score: {0:.1f}%".format(
        clf.score(X_train, y_train) * 100))

        X_test = vectorizer.transform(test_subset.data).todense()
        y_test = test_subset.target
        
        predicted = clf.predict(X_test)
        print(metrics.classification_report(y_test, predicted,
        target_names=test_subset.target_names))
        print("Accuracy: ",metrics.accuracy_score(y_test, predicted))
    
def getStopwords():
    stopwords_string = ""
    with open("stopwords.txt", "r") as stp:
        stopwords_string = stp.read()
    return stopwords_string.split()

def parseHTMLPage(html):
    soup = bs(html,'html.parser')
    for script in soup(["script","style"]):
        script.extract()
    raw_content = soup.getText().lower()
    
    return raw_content


if __name__ == '__main__':
    main()