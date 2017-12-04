class Create_inverted_table

require 'open-uri'
require 'nokogiri'

	def generate
		lines = read_file("C:/Users/jpms2/Desktop/RI/bookworm/Extractor/results.txt")
		html_lines = get_html_words()
		doc_name = ""
		authors = Hash.new([])
		titles = Hash.new([])
		prices = Hash.new([])
		publishers = Hash.new([])
		isbns = Hash.new([])
		others = Hash.new([])
		frequency = Hash.new()

		table_values = []
		html_lines = html_lines.gsub(/\n/,"")
		html_lines = html_lines.split(" ")
		html_name = ""

		html_lines.each do |html_word|
			word = normalize_word(html_word)
			match = false
			if (/\#\#\#\#\#\#.*\#\#\#\#\#\#/ =~ word)
				html_name = (/\#\#\#\#\#\#(.*)\#\#\#\#\#\#/.match word)[1].to_s
			else
				if frequency[word].nil?
					frequency[word] = {html_name => 1}
				else
					if frequency[word][html_name].nil?
						frequency[word] = {html_name => 1}
					end
				end
				i = 0
				while i < others[word].length
					if (/(\d.*)\(/.match (others[word][i]))[1].to_s == html_name
						match = true
						break
					end
					i = i + 1
				end
				if match
					others["other.#{word}"][i] = "#{html_name}(#{frequency[word][html_name] + 1})"
					frequency["other.#{word}"][html_name] = frequency[word][html_name] + 1
				else
					others["other.#{word}"] = others["other.#{word}"] + ["#{html_name}(#{frequency[word][html_name]})"]
				end
			end
		end

		lines.each do |line|
			if(/\/(.*\d+)\./ =~ line)
				doc_name = (/\/(.*\d+)\./.match line)[1].to_s
			end

			if line.include?("Author")
				author = normalize_author((/: (.*)/.match line)[1].to_s).capitalize
				authors["author.#{author}"] = authors["author.#{author}"] + ["#{doc_name}(1)"]
			elsif line.include?("Title")
				title = normalize_title((/: (.*)/.match line)[1].to_s).capitalize
				titles["title.#{title}"] = titles["title.#{title}"] + ["#{doc_name}(1)"]
			elsif line.include?("Price")
				price = (/: (.*)/.match line)[1].to_s
				price = normalize_price(price)
				prices["price.#{price}"] = prices["price.#{price}"] + ["#{doc_name}(1)"]
			elsif line.include?("Publisher")
				publisher = (/: (.*)/.match line)[1].to_s
				publisher = normalize(publisher).capitalize
				publishers["publisher.#{publisher}"] = publishers["publisher.#{publisher}"] + ["#{doc_name}(1)"]
			elsif line.include?("ISBN")
				isbn = normalize_isbn((/: (.*)/.match line)[1].to_s)
				isbns["isbn.#{isbn}"] = isbns["isbn.#{isbn}"] + ["#{doc_name}(1)"]
			end
		end
		real_authors = Hash.new([])
		real_titles = Hash.new([])
		real_prices = Hash.new([])
		real_publishers = Hash.new([])
		real_isbns = Hash.new([])
		real_others = Hash.new([])

		(authors.keys.sort).each do |author_keys|
			real_authors[author_keys] = authors[author_keys]
		end
		(titles.keys.sort).each do |title_keys|
			real_titles[title_keys] = titles[title_keys]
		end
		(prices.keys.sort).each do |price_keys|
			real_prices[price_keys] = prices[price_keys]
		end
		(publishers.keys.sort).each do |publisher_keys|
			real_publishers[publisher_keys] = publishers[publisher_keys]
		end
		(isbns.keys.sort).each do |isbn_keys|
			real_isbns[isbn_keys] = isbns[isbn_keys]
		end
		(others.keys.sort).each do |other_keys|
			real_others[other_keys] = others[other_keys]
		end

		table_values.push(real_authors)
		table_values.push(real_titles)
		table_values.push(real_prices)
		table_values.push(real_publishers)
		table_values.push(real_isbns)
		table_values.push(real_others)

		write_compressed(table_values)
	end

	def normalize_author(author)
		author = author.gsub(/<\/a>/, "")
		author = author.gsub(/<a.*>/, "")
		author = author.gsub(/\/.*\//, "")
		author = author.strip
	end

	def normalize_word(word)
		word = word.gsub(/\,/,"")
		word = word.gsub(/\./,"")
		word = word.gsub(/\'/,"")
		word = word.gsub(/\]/,"")
		word = word.gsub(/\[/,"")
		word = word.gsub(/\}/,"")
		word = word.gsub(/\{/,"")
		word = word.gsub(/\)/,"")
		word = word.gsub(/\(/,"")
		word = word.gsub(/\*/,"")
		word = word.gsub(/\&/,"")
		word = word.gsub(/\"/,"")
		word = word.gsub(/\%/,"")
		word = word.gsub(/\$/,"")
		word = word.gsub(/\?/,"")
		word = word.gsub(/\!/,"")
		word = word.gsub(/\:/,"")
		word = word.gsub(/\-/,"")
		word = word.gsub(/\//,"")
		word = word.gsub(/\\/,"")
		word = word.strip
	end

	def normalize_title(title)
		title = title.gsub(/Livro - /, "")
		title = title.gsub(/Box - /, "")
		title = title.gsub(/N.*s/, "Nos")
		title = title.gsub(/\?/, "")
		title = title.gsub(/mudan.*a/, "mudanca")
		title = title.gsub(/transi.*o/, "transicao")
		title = title.gsub(/l.*quia/, "liquia")
		title = title.gsub(/infla.*o/,"inflacao")
		title = title.gsub(/transi.*o/,"transicao")
		title = title.strip
	end

	def  normalize_price(price)
		price = price.gsub(/R\$ /, "")
		price = price.gsub(/R\$/, "")
		if(price.to_i <= 40)
			price = "[0, 40]"
		elsif (price.to_i > 40 && price.to_i <= 80)
				price = "(40, 80]"
		elsif (price.to_i > 80 && price.to_i <= 120)
				price = "(80, 120]"
		elsif (price.to_i > 120 && price.to_i <= 160)
				price = "(120, 160]"
		elsif (price.to_i > 160 && price.to_i <= 200)
				price = "(160, 200]"
		else
			price = "(200, ]"
		end
		price
	end

	def normalize_isbn(isbn)
		isbn = isbn.gsub(/-/, "")
	end

	def normalize(publisher)
		pub = ""
		pv = false
		par = false
		if /(.*);/ =~ publisher
			if par
				pub = (/(.*);/.match pub)[1].to_s
			else
				pub = (/(.*);/.match publisher)[1].to_s
			end
			if pub != ""
				pv = true
			end

		end

		if /(.*) \(/ =~ publisher
			if pv 
				if /(.*) \(/ =~ pub
					pub = (/(.*) \(/.match pub)[1].to_s
				end
			else
				pub = (/(.*) \(/.match publisher)[1].to_s
			end
			par = true

		end
		pub = pub.gsub(/Intr.*nseca/, "Intrinseca")
		publisher = publisher.gsub(/Intr.*nseca/, "Intrinseca")
		publisher = publisher.gsub(/ books/, "")
		pub = pub.gsub(/ books/, "")
		publisher = publisher.gsub(/ comics/, "")
		pub = pub.gsub(/ comics/, "")
		publisher = publisher.gsub(/Editora /, "")
		pub = pub.gsub(/Editora /, "")
		publisher = publisher.gsub(/ livros/, "")
		pub = pub.gsub(/ livros/, "")
		if pub == ""
			publisher
		else
			pub
		end
	end

	def get_html_words()
		files = Dir["C:/Users/jpms2/Desktop/RI/bookworm/working/*.html"]
		text = ''
		files.each do |path|
			filename = ((/[^\/]*$/.match path).to_s)[0..-6]
			filename = filename.gsub(/casasbahia/,"0")
			filename = filename.gsub(/estantevirtual/,"1")
			filename = filename.gsub(/livrariacultura/,"2")
			filename = filename.gsub(/livrariafolha/,"3")
			filename = filename.gsub(/saraiva/,"4")
			filename = filename.gsub(/submarino/,"5")
			filename = filename.gsub(/amazon/,"6")
			file = File.read(path)
			doc = Nokogiri::HTML(file)
			text << "\#\#\#\#\#\##{filename}\#\#\#\#\#\# "
			doc.css('p,h1').each do |e|
			  text << e.content
			end
		end
		text
	end

	def read_file(path)
	    array_line = []
	    File.foreach(path) do |line|
	      array_line.push line
	    end
	    array_line
  	end

  	def write(table_values)
  		text = ""
  		table_values.each do |table_value|
  			table_value.each do |key, value_arr|
  				text = text + "#{key}".force_encoding(::Encoding::UTF_8)
  				value_arr.each do |value|
  					text = text + ",#{value}"
  				end
  				text = text + "\n"
  			end
  		end
	    File.open("#{__dir__}/inverted_index.txt", 'w') do |f|
	      f.write text
	    end
  	end

  	def write_compressed(table_values)
  		text = ""
  		last_value = 0
  		table_values.each do |table_value|
  			table_value.each do |key, value_arr|
  				text = text + "#{key}".force_encoding(::Encoding::UTF_8)
  				last_value = 0
  				value_arr.each do |value|
  					nxt = (/(\d.*)\(/.match value)[1].to_i - last_value
  					text = text + ",#{nxt}(#{(/\((\d.*)\)/.match value)[1]})"
  					last_value = (/(\d.*)\(/.match value)[1].to_i
  				end
  				text = text + "\n"
  			end
  		end
	    File.open("#{__dir__}/inverted_index.txt", 'w') do |f|
	      f.write text
	    end
  	end

end
Create_inverted_table.new.generate