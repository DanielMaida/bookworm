require_relative 'retrieve_data'

class Extract_data

  def extract_save(folder_path)

  	check_delete_old
		files = Dir["#{folder_path}/*.html"]
		files.each do |path|
			info = Info.new
			text = []

			info = collect_data(path)

			if !info.nil?
				text.push("###################{/\/(?:.(?!\/))+$/.match(path)}########################\n")
				if !info.title.nil?
					text.push("Title: #{info.title}")
				end
		  		if !info.author.nil?
		  			text.push("Author: #{info.author}")
		  		end
		  		if !info.price_physical.nil?
		  			text.push("Price: #{info.price_physical}")
		  		end
		  		if !info.publisher.nil?
		  			text.push("Publisher: #{info.publisher}")
		  		end
		  		if !info.pages.nil?
		  			text.push("Page number: #{info.pages}")
		  		end
		   	    if !info.isbn.nil?
		   	  	    text.push("ISBN: #{info.isbn}")
		   	    end
		   	    if !info.weight.nil?
		   	    	text.push("Weight:#{info.weight}")
		   	    end
		   	    if !info.dimensions.nil?
		   	    	text.push("Dimensions: #{info.dimensions}")
		   	    end
		   	    if !info.especifications.nil?
		   	    	text.push("Especifications: #{info.especifications}")
		   	    end
		   	    if !info.language.nil?
		   	    	text.push("Language: #{info.language}")
		   	    end
		   	    if !info.year.nil?
		   	    	text.push("Published in: #{info.year}")
		   	    end
		   	    if !info.edition.nil?
		   	    	text.push("Edition: #{info.edition}")
		   	    end		   	    
			end
   	  save_to_file(text, path)
		end
  end

  def collect_data(path)
		retrieve_data = Retrieve_data.new
  	info = Info.new

		if path.include?('americanas')
			info = retrieve_data.retrieve_americanas path
		end
		if path.include?('amazon')
			info = retrieve_data.retrieve_amazon path
		end
		if path.include?('cultura')
			info = retrieve_data.retrieve_cultura path
		end
		if path.include?('fnac')
			info = retrieve_data.retrieve_fnac path
		end
		if path.include?('folha')
			info = retrieve_data.retrieve_folha path 
		end
		if path.include?('casasbahia')
			info = retrieve_data.retrieve_casas_bahia path
		end
		if path.include?('estantevirtual')
			info = retrieve_data.retrieve_estante_virtual path
		end
		if path.include?('magazineluiza')
			info = retrieve_data.retrieve_magazine_luiza path
		end
		if path.include?('saraiva')
			info = retrieve_data.retrieve_saraiva path
		end
		if path.include?('submarino')
			info = retrieve_data.retrieve_submarino path
		end

		info
	end

	def check_delete_old
		if File.exist?("#{__dir__}/results.txt")
  		File.delete("#{__dir__}/results.txt")
  	end
  end

  def save_to_file(text, path)
  	
  	open("#{__dir__}/results.txt", 'a:UTF-8') { |f|
  		text.each do |line|
  			if !(path.include? 'estantevirtual') && !(path.include? 'folha')
  				f.puts line.encode("iso-8859-1", invalid: :replace, undef: :replace).force_encoding("utf-8")
  			else
  				if (path.include? 'folha')
  					f.puts line.encode("windows-1252", invalid: :replace, undef: :replace).force_encoding("utf-8")
  				else
  					f.puts line
  				end
  			end
  		end
		}
	end
end