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
				if frequency["other.#{word}"].nil?
					frequency["other.#{word}"] = {html_name => 1}
				else
					if frequency["other.#{word}"][html_name].nil?
						frequency["other.#{word}"] = {html_name => 1}
					end
				end
				i = 0
				while i < others["other.#{word}"].length
					if (/(\d.*)\(/.match (others["other.#{word}"][i]))[1].to_s == html_name
						match = true
						break
					end
					i = i + 1
				end
				other_pos = "other.#{word}"
				if match
					others["other.#{word}"][i] = "#{html_name}(#{frequency[other_pos][html_name] + 1})"
					frequency["other.#{word}"][html_name] = frequency["other.#{word}"][html_name] + 1
				else
					others["other.#{word}"] = others["other.#{word}"] + ["#{html_name}(#{frequency[other_pos][html_name]})"]
				end
			end
		end

		lines.each do |line|
			if(/\/(.*\d+)\./ =~ line)
				doc_name = (/\/(.*\d+)\./.match line)[1].to_s
				doc_name = setup_filename(doc_name)
			end

			if line.include?("Author")
				author = normalize_author((/: (.*)/.match line)[1].to_s)
				author_raw = normalize_word(author)
				author_values = author_raw.split(" ")
				author_values.each do |author|
					author = author.capitalize
					authors["author.#{author}"] = (authors["author.#{author}"] + ["#{doc_name}"]).uniq
				end
			elsif line.include?("Title")
				title = normalize_title((/: (.*)/.match line)[1].to_s)
				title_raw = normalize_word(title)
				title_values = title_raw.split(" ")
				title_values.each do |title|
					title = title.capitalize
					titles["title.#{title}"] = (titles["title.#{title}"] + ["#{doc_name}"]).uniq
				end
			elsif line.include?("Price")
				price = (/: (.*)/.match line)[1].to_s
				price = normalize_price(price)
				prices["price.#{price}"] = (prices["price.#{price}"] + ["#{doc_name}"]).uniq
			elsif line.include?("Publisher")
				publisher = (/: (.*)/.match line)[1].to_s
				publisher = normalize(publisher)
				publisher_raw = normalize_word(publisher)
				publisher_values = publisher_raw.split(" ")
				publisher_values.each do |publisher|
					publisher = publisher.capitalize
					publishers["publisher.#{publisher}"] = (publishers["publisher.#{publisher}"] + ["#{doc_name}"]).uniq
				end
			elsif line.include?("ISBN")
				isbn = normalize_isbn((/: (.*)/.match line)[1].to_s)
				isbns["isbn.#{isbn}"] = (isbns["isbn.#{isbn}"] + ["#{doc_name}"]).uniq
			end
		end
		real_authors = Hash.new([])
		real_titles = Hash.new([])
		real_prices = Hash.new([])
		real_publishers = Hash.new([])
		real_isbns = Hash.new([])
		real_others = Hash.new([])

		(authors.keys.sort).each do |author_keys|
			correct_values = []
			(authors[author_keys].map(&:to_i).sort).map(&:to_s).each do |value|
				true_value = value
				if value.to_i < 100
					true_value = "0#{value}"
				end
				correct_values.push("#{true_value}(1)")
			end
			real_authors[author_keys] = correct_values
		end
		(titles.keys.sort).each do |title_keys|
			correct_values = []
			(titles[title_keys].map(&:to_i).sort).map(&:to_s).each do |value|
				true_value = value
				if value.to_i < 100
					true_value = "0#{value}"
				end
				correct_values.push("#{true_value}(1)")
			end
			real_titles[title_keys] = correct_values
		end
		(prices.keys.sort).each do |price_keys|
			correct_values = []
			(prices[price_keys].map(&:to_i).sort).map(&:to_s).each do |value|
				true_value = value
				if value.to_i < 100
					true_value = "0#{value}"
				end
				correct_values.push("#{true_value}(1)")
			end
			correct_values = correct_values.uniq
			real_prices[price_keys] = correct_values
		end
		(publishers.keys.sort).each do |publisher_keys|
			correct_values = []
			(publishers[publisher_keys].map(&:to_i).sort).map(&:to_s).each do |value|
				true_value = value
				if value.to_i < 100
					true_value = "0#{value}"
				end
				correct_values.push("#{true_value}(1)")
			end
			real_publishers[publisher_keys] = correct_values
		end
		(isbns.keys.sort).each do |isbn_keys|
			correct_values = []
			(isbns[isbn_keys].map(&:to_i).sort).map(&:to_s).each do |value|
				true_value = value
				if value.to_i < 100
					true_value = "0#{value}"
				end
				correct_values.push("#{true_value}(1)")
			end
			real_isbns[isbn_keys] = correct_values
		end
		(others.keys.sort).each do |other_keys|
			real_others[other_keys] = order_others(others[other_keys])
		end

		table_values.push(real_authors)
		table_values.push(real_titles)
		table_values.push(real_prices)
		table_values.push(real_publishers)
		table_values.push(real_isbns)
		table_values.push(real_others)

		write_compressed(table_values)
	end

	def order_others(array)
		sorted_array = []
		result_array = []
		regex = /(.*)\(/
		array.each do |value|
			if (/^\d\d\d*\d*/ =~ value)
				sorted_array.push(/(.*)\(/.match(value)[1])
			end
		end
		sorted_array = sorted_array.map(&:to_i).sort
		sorted_array.each do |sorted_value|
			array.each do |value|
				if /(.*)\(/.match(value)[1].to_i == sorted_value
					result_array.push(value)
					break
				end
			end
		end
		result_array.uniq
	end

	def normalize_author(author)
		author = author.gsub(/<\/a>/, "")
		author = author.gsub(/<.*>/, "")
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
			filename = setup_filename(filename)
			file = File.read(path)
			doc = Nokogiri::HTML(file)
			text << "\#\#\#\#\#\##{filename}\#\#\#\#\#\# "
			doc.css('p,h1').each do |e|
			  text << e.content
			end
		end
		text
	end

	def setup_filename(filename)
		filename = filename.gsub(/casasbahia/,"1")
		filename = filename.gsub(/estantevirtual/,"2")
		filename = filename.gsub(/livrariacultura/,"3")
		filename = filename.gsub(/livrariafolha/,"4")
		filename = filename.gsub(/saraiva/,"5")
		filename = filename.gsub(/submarino/,"6")
		filename = filename.gsub(/amazon/,"7")
		filename = filename.gsub(/americanas/,"8")
		filename
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