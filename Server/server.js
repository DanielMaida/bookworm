var express = require('express');
var app = express();
var linkIdMap = require("../InvertedFile/linkIdMap.json");

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
	if(author){
		//TO DO: query using these fields
		//lembrar de transformar @ em " antes de mandar de volta, ou na tela msm sei lá

		//FAZER CHAMADA DO PYTHON PASSANDO OS PARAMS
		/*const execSync = require('child_process').execSync;
		code = execSync('node -v');*/

		var resultados = [];

		var rd = readline.createInterface({
		    input: fs.createReadStream('queryResult.txt'),		    
		    console: false
		});

		rd.on('line', function(line) {
		    resultados.push({author:"",title:"",publisher:"",isbn:"",link:linkIdMap[line].replace(/@/g, "\"")});//espero que funcione =|
		}).on('close', function() {
		    	res.render('pages/index', {renderResultTable:true, query:query, resultados:resultados});
		});
		
	}else{
		res.render('pages/index', {renderResultTable:false, query:query});
	}

});

app.listen(8080);
console.log('server listening on the 8080 port');