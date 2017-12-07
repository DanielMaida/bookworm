var express = require('express');
var app = express();
var linkIdMap = require("../InvertedFile/linkIdMap.json");
var invertedIndex = require("../InvertedFile/inverted-index.json");
var reverseEngineerAtributeFile = require("../InvertedFile/inverted_index-old.json");
var fs = require('fs');
var readline = require('readline');
var util = require('util');

var NUMBEROFDOCUMENTS = 7000;

if(!fs.existsSync("../InvertedFile/mutualInfo.json")){
	processMutualInfo();
}
var mutualInfoWords = require("../InvertedFile/mutualInfo.json");

// set the view engine to ejs
app.set('view engine', 'ejs');

// index page 
app.get('/', function(req, res) {
	var query = req.query;
	var author = query.author;
	var title = query.title;
	var publisher = query.publisher;
	var isbn = query.isbn;
	var other = query.other;
	var price = query.price;

	if(author){
		//TO DO: query using these fields

		//FAZER CHAMADA DO PYTHON PASSANDO OS PARAMS
		/*const execSync = require('child_process').execSync;
		code = execSync('node -v');*/

		var rd = readline.createInterface({
		    input: fs.createReadStream('queryResult.txt'),		    
		    console: false
		});

		//ler até chegar em other..., só ler a lista uma vez, juntar tudo num objeto mandar para a tabela de respostas =)

		var documentIds = [];
		rd.on('line', function(line) {
			documentIds.push(line);					  
		}).on('close', function() {		
				//resultados.push({author:"",title:"",publisher:"",isbn:"",link:linkIdMap[line].replace(/~/g, "\"")});//espero que funcione =|		    			    	
		    	res.render('pages/index', {renderResultTable:true, query:query, resultados:getResults(documentIds), recommendations:getRecommendations(author,title,publisher)});
		});
		
	}else{
		res.render('pages/index', {renderResultTable:false, query:query});
	}

});

function getRecommendations(author,title,publisher){
	var result = {};
	author = "author." + author;
	title = "title." + title;
	publisher = "publisher." + publisher;

	if(mutualInfoWords[author])
		result.author = mutualInfoWords[author].map(function(e){
			return e.substring(e.indexOf(".")+1);
		}).join(", ");
	
	if(mutualInfoWords[title])
		result.title = mutualInfoWords[title].map(function(e){
			return e.substring(e.indexOf(".")+1);
		}).join(", ");
	
	if(mutualInfoWords[publisher])
		result.publisher = mutualInfoWords[publisher].map(function(e){
			return e.substring(e.indexOf(".")+1);
		}).join(", ");

	result.hasRecommendations = !(!result.author && !result.title && !result.publisher);;
	return result;
}

function getResults(documentIds){
	var results = [];
	
	documentIds.map(function(documentId){
		results.push({id:documentId,author:"-",title:"-",publisher:"-", isbn:"-",price:"-", link:linkIdMap[documentId]});
	});

	//Remontando atributos do documento a partir do indice invertido, porque não tenho acesso aos pares de atributo-valor
	for (var key in reverseEngineerAtributeFile) {
	    if (reverseEngineerAtributeFile.hasOwnProperty(key)) {

	    	if(!key.startsWith("other")){
	    		//iterar sobre as listas
	    		var id = 0;	    		
	    		reverseEngineerAtributeFile[key].forEach(function(e,i){
	    			id += e.id;	    			
	    			if(documentIds.includes(id.toString())){
	    				var arrayIndex = results.findIndex(result => result.id == id);
	    				key.replace(/~/g, "\"");
	    				if(key.startsWith("author")){							
							results[arrayIndex].author = key.replace("author.","");
						}else if(key.startsWith("title")){
							results[arrayIndex].title = key.replace("title.","");
						}else if(key.startsWith("publisher")){
							results[arrayIndex].publisher = key.replace("publisher.","");
						}else if(key.startsWith("isbn")){
							results[arrayIndex].isbn = key.replace("isbn.","");											
						}else if(key.startsWith("price")){
							results[arrayIndex].price = "R$ " + key.replace("price.","");					
						}	    			
    			}});
	    			
	    	}else{
	    		//chegou no other
	    		break;
	    	}
	    }
	}

	return results;
}

function processMutualInfo(){
	var result = {};
	for (var key in invertedIndex) {
	    if (invertedIndex.hasOwnProperty(key)) {
	    	if(key.startsWith("other")){
	    		break;
	    	}	    
	    	var mutualInfoList = calculateMutualInfo(key);
	    	
	    	mutualInfoList = mutualInfoList.sort(function(a,b){return a["mutualInfo"]-b["mutualInfo"]});
	    	mutualInfoList = mutualInfoList.slice(0,3).map(function(e){
				return e["word"];
			});

	    	if(mutualInfoList.length != 0){
	    		result[key] = mutualInfoList;
	    	}		
	    }
	}

	fs.writeFileSync("../InvertedFile/mutualInfo.json",JSON.stringify(result),'utf-8');
}
	
function calculateMutualInfo(word){
	var type = word.substring(0,word.indexOf("."));
	var mutualInfoListForWord = [];
	var PA = invertedIndex[word].length / NUMBEROFDOCUMENTS;

	for (var key in invertedIndex) {
	    if (invertedIndex.hasOwnProperty(key)) {
	    	if(key.startsWith(type) && key != word){

	    		var innerJoin = expandInvertedList(invertedIndex[word]).filter((id) => expandInvertedList(invertedIndex[key]).includes(id));	    
	    		var PAB = innerJoin.length;
	    		if(PAB == 0){ //não tem interseção
	    			continue;
	    		}
	    		var PB = invertedIndex[key].length / NUMBEROFDOCUMENTS;
	    		var mutualInfo = Math.log2(PAB/(PA*PB));
	    		mutualInfoListForWord.push({"word":key,"mutualInfo":mutualInfo});

	    	}else{
	    		continue;
	    	}
		}
	}
	return mutualInfoListForWord;
}

function expandInvertedList(indexes){
	var documentId = 0;
	var result = [];
	indexes.forEach(function(e,i){
		documentId+= e.id;
		result.push(documentId);
	});
	return result;
}

app.listen(8080);
console.log('server listening on the 8080 port');