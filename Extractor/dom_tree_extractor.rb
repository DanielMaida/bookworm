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
		data_array
	end

	#- fnac miss 
	#- cultura hit
	#- saraiva miss 
	#- casas bahia hit
	#- amazon hit
	#- livraria folha half-hit
	#- estante virtual miss 
	#- americanas hit 
	#- submarino hit
	#- magazine luiza half-hit
	def extract_reject_long_strings(path)
		data_array = []
		html = File.read(path)
		doc = Nokogiri::HTML(html)
		elems  = doc.search "[text()*='ISBN']"
		if !elems.first.nil?
			if elems.first.to_s.length < 220
				elem  = elems.first.parent
			else
				elem = elems.last.parent
			end
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
		data_array
	end
	
    #- fnac miss
	#- cultura hit
	#- saraiva miss 
	#- casas bahia hit
	#- amazon hit
	#- livraria folha hit
	#- estante virtual hit 
	#- americanas hit 
	#- submarino hit
	#- magazine luiza hit
	def extract_parent(path)
		data_array = []
		first_time = true
		html = File.read(path)
		doc = Nokogiri::HTML(html)
		elems  = doc.search "[text()*='ISBN']"
		if !elems.first.nil?
			if elems.first.to_s.length < 220
				elem  = elems.first.parent
			else
				elem = elems.last.parent
			end
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
					if old_elem.previous_element.to_s != ''
						elem = old_elem.previous_element
						foward = false
					else
						if data_array.length < 3
							if first_time	
								data_array = []
								first_time = false
							end
							elem = elem.parent
							old_elem = elem
						else
							elem = ''
						end
					end
				end
			else
				if elem.previous_element.to_s != ''
					elem = elem.previous_element
				else
					elem = ''
				end
			end
		end
		data_array
	end

end