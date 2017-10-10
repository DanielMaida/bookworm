#- fnac done /
#- cultura done/
#- saraiva done
#- casas bahia done/
#- amazon done/
#- livraria folha done/
#- estante virtual done/
#- americanas done/
#- submarino done
#- magazine luiza done
class Retrieve_data

	def retrieve_folha(path)
		info = Info.new
		info.price_physical = ''
		match_title = />(T.*?tulo):</
		match_author = />(Autor):</
		match_price = /<ins>.*: (.*)<\/i/
		match_isbn = />(ISBN):</
		match_weight = />(Peso):</
		match_dimensions = />(Dimens.*?es):</
		match_especifications = />(Especifica.*?es):</
		match_language = />(Idioma):</
		match_year = />(Ano):</
		match_edition = />(Edi.*?o):</
		match_publisher = />(Editora):</
		file_lines = read_file path
		file_lines.each_with_index do |line, i|
			if match_title =~ line
				info.title = (/>(.*)</.match file_lines[i + 1])[1]
			end
			if match_author =~ line
				if file_lines[i + 1].include? 'href'
					info.author = (/">(.*)</.match file_lines[i + 1])[1].to_s
				else
					info.author = (/>(.*)</.match file_lines[i + 1])[1].to_s
				end
			end
			if match_price =~ line && info.price_physical == ''
				info.price_physical = (match_price.match line)[1].force_encoding(::Encoding::UTF_8)
			end
			if match_isbn =~ line
				info.isbn = (/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8)
			end
			if match_weight =~ line
				info.weight = (/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8)
			end
			if match_dimensions =~ line
				info.dimensions = (/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8)
			end
			if match_especifications =~ line
				info.especifications = ((/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8))
			end
			if match_language =~ line
				info.language = (/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8)
			end
			if match_year =~ line
				info.year = (/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8)
			end
			if match_edition =~ line
				info.edition = (/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8)
			end
			if match_publisher =~ line
				info.publisher = (/>(.*)</.match file_lines[i + 1])[1].to_s.force_encoding(::Encoding::UTF_8)
			end
		end
		info
	end

	def retrieve_magazine_luiza(path)
		info = Info.new
		info.author = ''
		match_title = /h1 .*?>(.*?)</
		match_author = /Autor .*?">(.*?)</
		match_price = /te__t.*?>(.*?)</
		match_isbn = /ISBN.*?">(.*?)</
		file_lines = read_file path
		file_lines.each do |line|
			if match_title =~ line
				title_publisher = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
				info.title = (/(.*?) -.*/.match (title_publisher))[1]
				if /-(.*?)-/ =~ title_publisher.reverse!
			    	info.publisher = (/-(.*?)-/.match (title_publisher.reverse!))[1].reverse!.strip
				end
			end
			if match_author =~ line && info.author == ''
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8).strip
			end
			if match_price =~ line
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_isbn =~ line
				info.isbn = (clean_output (match_isbn.match line)[1]).force_encoding(::Encoding::UTF_8).gsub(/\s+/, "")
			end
		end		
		info
	end


	def retrieve_submarino(path)
		info = Info.new
		info.author = ''
		match_title = /h1 i.*?>(.*?)</
		match_author = /Autor.*?:"(.*?)"/
		match_price = /<p class="sales-price.*?>(R\$ \d+,\d+)</
		match_publisher = /Editora.*?:"(.*?)"/
		match_isbn = /ISBN.*?:"(.*?)"/
		match_pages = /P.*?ginas.*?:"(.*?)"/
		file_lines = read_file path
		file_lines.each do |line|
			if match_title =~ line
				info.title = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_author =~ line && info.author == ''
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_price =~ line
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_isbn =~ line
				info.isbn = (clean_output (match_isbn.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_pages =~ line
				info.pages = (clean_output (match_pages.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_publisher =~ line
				info.publisher = (clean_output (match_publisher.match line)[1]).force_encoding(::Encoding::UTF_8)
				if info.publisher[0] == ' '
					info.publisher = info.publisher[1..-1]
				end
			end
		end		
		info
	end


	def retrieve_americanas(path)
		info = Info.new
		info.author = ''
		match_title = /<td.*?>T.*?tulo.*?">(.*?)</
		match_subtitle = /<td.*?>Subt.*?">(.*?)</
		match_author = /<td.*?>Autor.*?">(.*?)</
		match_price = /<p class="sales-price.*?>(R\$ \d+,\d+)</
		match_publisher = /<td.*?>Editora.*?">(.*?)</
		match_isbn = /<td.*?>ISBN.*?">(.*?)</
		match_pages = /<td.*?>P.*?ginas.*?">(.*?)</
		file_lines = read_file path
		file_lines.each do |line|
			if match_title =~ line
				if match_subtitle =~ line
					info.title = "#{((clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8))}: #{((clean_output (match_subtitle.match line)[1]).force_encoding(::Encoding::UTF_8))}"
				else
					info.title = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
				end
			end
			if match_author =~ line && info.author == ''
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_price =~ line
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_isbn =~ line
				info.isbn = (clean_output (match_isbn.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_pages =~ line
				info.pages = (clean_output (match_pages.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_publisher =~ line
				info.publisher = (clean_output (match_publisher.match line)[1]).force_encoding(::Encoding::UTF_8)
				if info.publisher[0] == ' '
					info.publisher = info.publisher[1..-1]
				end
			end
		end		
		info
	end


	def retrieve_estante_virtual(path)
		info = Info.new
		info.author = ''
		match_title = /h1 class="busca-title.*?>(.*)</
		match_author = /h2 class="busca-author.*?>.*?>(.*)<\/a/
		match_price = /<li class="price-book">(.*)</
		match_publisher = /Editora:<\/strong>(.*)</
		filled_p = false
		filled_pu = false
		file_lines = read_file path
		file_lines.each do |line|
			if match_title =~ line
				info.title = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_author =~ line && info.author == ''
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_price =~ line && !filled_p
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
				filled_p = true
			end
			if match_publisher =~ line && !filled_pu
				info.publisher = (clean_output (match_publisher.match line)[1]).force_encoding(::Encoding::UTF_8)
				filled_pu = true
				if info.publisher[0] == ' '
					info.publisher = info.publisher[1..-1]
				end
			end
		end		
		info
	end

	def retrieve_amazon(path)
		info = Info.new
		info.author = ''
		match_title = /productTitle".*?>(.*)</
		match_author = /field-author.*?>(.*)</
		match_price = /offer-price.*?>(R\$ \d+,\d+)/
		match_publisher = /<b>Editora.*?>(.*)</
		match_pages = /.* (\d+\d*\d*\d*) p.+ginas/
		match_isbn = /ISBN-10.* (\d+)/
		file_lines = read_file path
		file_lines.each do |line|
			if match_title =~ line
				info.title = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_author =~ line && info.author == ''
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_price =~ line
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_publisher =~ line
				info.publisher = (clean_output (match_publisher.match line)[1]).force_encoding(::Encoding::UTF_8)
				if info.publisher[0] == ' '
					info.publisher = info.publisher[1..-1]
				end
			end
			if match_pages =~ line
				info.pages = (clean_output (match_pages.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_isbn =~ line
				info.isbn = (clean_output (match_isbn.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
		end		
		info
	end


	def retrieve_casas_bahia(path)
		info = Info.new
		info.title = ''
		title = false
		author = false
		publisher = false
		pages = false
		isbn = false
		attr_match = /                                            (.+)/
		match_title = /<b itemprop.*?>(.*?)</
		match_price = /i class="sale price">(\d+,\d+)/
		match_author = /<b>Autor.*?">(.*?)</
		match_price_alt = /<h3 class="price">(R\$ \d+,\d+)/
		match_publisher = /<strong class="brand" .*?>(.*)<\/st/
		match_pages = "Número de Páginas"
		file_lines = read_file path
		file_lines.each do |line|
			if /  .+Tí/.match line.force_encoding(::Encoding::UTF_8)
				title = true
			end
			if / .+Autor/.match line.force_encoding(::Encoding::UTF_8)
				author = true
			end
			if /  .+Editora/.match line.force_encoding(::Encoding::UTF_8)
				publisher = true
			end
			if /N*mero de P.*ginas/ =~ line.force_encoding(::Encoding::UTF_8) 
				pages = true
			end
			if / ISBN$/ =~ line
				isbn = true
			end
			if match_price =~ line
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if title && attr_match =~ line
				info.title = (clean_output (attr_match.match line)[1]).force_encoding(::Encoding::UTF_8)
				title = false
			end
			if author && attr_match =~ line
				info.author = (clean_output (attr_match.match line)[1]).force_encoding(::Encoding::UTF_8)
				author = false
			end
			if publisher && attr_match =~ line
				info.publisher = (clean_output (attr_match.match line)[1]).force_encoding(::Encoding::UTF_8)
				publisher = false
			end
			if match_title =~ line && info.title == ''
				info.title =  (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if pages && attr_match =~ line
				info.pages = (clean_output (attr_match.match line)[1]).force_encoding(::Encoding::UTF_8)
				pages = false
			end
			if isbn && attr_match =~ line
				info.isbn = (clean_output (attr_match.match line)[1]).force_encoding(::Encoding::UTF_8)
				isbn = false
			end
		end
		info
	end

	def retrieve_cultura(path)
		info = Info.new
		info.price_physical = ''
		match_price = /<h2 class="price">(R\$ \d+,\d+)/
		match_title = /<h1 class="title.*?>(.+?)<\/h1></
		match_author = /<b>Autor.*?">(.*?)</
		match_price_alt = /<h3 class="price">(R\$ \d+,\d+)/
		match_isbn = /<b>ISBN.*?(\d+)</
		match_pages = /<b>N.* de P.*ginas.*?(\d+)</
		match_publisher = /<b>Editora.*?">(.*)<\/a><\/li>/
		file_lines = read_file path
		file_lines.each do |line|
			if match_title =~ line
				info.title = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_author =~ line
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_price =~ line && info.price_physical == ''
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			end		
			if match_price_alt =~ line
				info.price_physical = (clean_output (match_price_alt.match line)[1]).force_encoding(::Encoding::UTF_8)
			end		
			if match_isbn =~ line
				info.isbn = (clean_output (match_isbn.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_pages =~ line
				info.pages = (clean_output (match_pages.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_publisher =~ line
				pub = (clean_output (match_publisher.match line)[1]).force_encoding(::Encoding::UTF_8)
				if !pub.include? '<'
					info.publisher = pub
				else
					info.publisher = (/(.*?)</.match pub)[1].force_encoding(::Encoding::UTF_8)
				end
			end
		end
		info
	end

	def retrieve_saraiva(path)
		info = Info.new
		info.price_physical = ''
		match_title = /<h1.*?>(.*)<s/
		match_author = /<h2 class="contributor livedata.*" .*?>(.*)</
		match_publisher = /<h2 class="brand livedata.*" .*?>(.*)</
		match_price_phy = /sico<\/span><span class="price".*?>(.*)<\/span><\/a><a/
		match_final_price = /.+(R\$ \d+,\d+) +/
		match_normal_price = /<span class="price-.*>(R\$ \d+,\d+)/
		match_isbn = /isbn.*?(\d+)/
		match_pages = /mero de P.*?ginas.*?(\d+)/
		file_lines = read_file path
		file_lines.each do |line|
			case line
			when match_title
				info.title = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
			when match_author
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8)
			when match_publisher
				info.publisher = (clean_output (match_publisher.match line)[1]).force_encoding(::Encoding::UTF_8)
			when match_normal_price
				info.price_physical = (clean_output (match_normal_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			when match_price_phy
				info.price_physical = (clean_output (match_price_phy.match line)[1]).force_encoding(::Encoding::UTF_8)
			when match_final_price
				if info.price_physical == ''
					info.price_physical = (clean_output (match_final_price.match line)[1]).force_encoding(::Encoding::UTF_8)
				end
			when match_isbn
				info.isbn = (clean_output (match_isbn.match line)[1]).force_encoding(::Encoding::UTF_8)
			when match_pages
				info.pages = (clean_output (match_pages.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
		end
		info
	end

	def retrieve_fnac(path)
		info = Info.new
		match_price = /price-cash.*>(R\$ \d+,\d+)<s/
		match_title = /<h1><div.*>(.+)<\/div><i/
		match_author = /class="brandName.*>(.+)<\/a/
		match_price_alt = /<strong class="skuB.*>(R\$ \d+,\d+)<\/st/
		match_isbn = /isbn10.*?(\d+)/
		file_lines = read_file path
		file_lines.each do |line|
			if match_title =~ line
				info.title = (clean_output (match_title.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_author =~ line
				info.author = (clean_output (match_author.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_price =~ line
				info.price_physical = (clean_output (match_price.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_price_alt =~ line
				info.price_physical = (clean_output (match_price_alt.match line)[1]).force_encoding(::Encoding::UTF_8)
			end
			if match_isbn =~ line
				info.isbn = (clean_output (match_isbn.match line)[1]).force_encoding(::Encoding::UTF_8)
			end						
		end
		info
	end

  def read_file(path)
    array_line = []
    File.foreach(path) do |line|
      array_line.push line
    end
    array_line
  end

  def clean_output(str)
  	str = str.gsub(/&gt;/,">")
    str = str.gsub(/&lt;/,"<")
    str = str.gsub(/&#39;/,"'")
    str = str.gsub(/&quot;/,"\"")
    str = str.gsub(/&amp;/,"&")
    str
  end

end

class Info
	attr_accessor :title
	attr_accessor :author
	attr_accessor :publisher
	attr_accessor :price_physical
	attr_accessor :pages
	attr_accessor :isbn
	attr_accessor :weight
	attr_accessor :dimensions
	attr_accessor :especifications
	attr_accessor :language
	attr_accessor :year
	attr_accessor :edition
end