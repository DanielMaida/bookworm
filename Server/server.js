var express = require('express');
var app = express();
var linkIdMap = require("../InvertedFile/linkIdMap.json");
var invertedIndex = require("../InvertedFile/inverted-index.json");

var fs = require('fs'),
    readline = require('readline');   

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
		//lembrar de transformar @ em " antes de mandar de volta, ou na tela msm sei lá

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
		    	res.render('pages/index', {renderResultTable:true, query:query, resultados:getResults(documentIds)});
		});
		
	}else{
		res.render('pages/index', {renderResultTable:false, query:query});
	}

});

function getResults(documentIds){
	var results = [];
	
	documentIds.map(function(documentId){
		results.push({id:documentId,author:"-",title:"-",publisher:"-", isbn:"-",price:"-", link:linkIdMap[documentId]});
	});

	for (var key in invertedIndex) {
	    if (invertedIndex.hasOwnProperty(key)) {

	    	if(!key.startsWith("other")){
	    		//iterar sobre as listas
	    		var id = 0;	    		
	    		invertedIndex[key].forEach(function(e,i){
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

function getSuggestions(word){


}

app.listen(8080);
console.log('server listening on the 8080 port');