require 'nokogiri'

class Dom_tree_extractor


	#- fnac miss 
	#- cultura hit
	#- saraiva miss 
	#- casas bahia hit
	#- amazon hit
	#- livraria folha half-hit
	#- estante virtual miss 
	#- americanas miss 
	#- submarino miss
	#- magazine luiza half-hit	
	def extract(path)
		data_array = []
		html = File.read(path)
		doc = Nokogiri::HTML(html)
		elems  = doc.search "[text()*='ISBN']"
		if !elems.first.nil?
			elem   = elems.first.parent
		else
			elem = ''
		end
		old_elem = elem
		foward = true

		while elem.to_s != ''
			parsed_elem = Nokogiri::HTML(elem.to_s)
			result_elem = (parsed_elem.xpath("//text()").to_s).gsub("\n", " ").to_s.gsub(/ +/, " ").force_encoding("utf-8")
			if result_elem.length < 220
				data_array.push(result_elem)
			end
			if foward
				if elem.next_element.to_s != ''
					elem = elem.next_element
				else
					elem = old_elem.previous_element
					foward = false
				end
			else
				if elem.previous_element.to_s != ''
					elem = elem.previous_element
				else
					elem = ''
				end
			end
		end
		puts 'result:'
		puts data_array
	end
	
end