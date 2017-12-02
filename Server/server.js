var express = require('express');
var app = express();

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
		res.render('pages/index', {renderResultTable:true, query:query, resultados:[]});
	}else{
		res.render('pages/index', {renderResultTable:false, query:query});
	}

});

app.listen(8080);
console.log('server listening on the 8080 port');