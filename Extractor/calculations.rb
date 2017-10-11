require_relative 'extract_data'
require_relative 'dom_tree_extractor'

class Calculations

	def avg_precision_recall_measure(folder_path)
		precision = 0
		recall = 0
		f_measure = 0
		zero_p = 0
		zero_r = 0
		zero_f = 0
		results_arr = []
		files = Dir["#{folder_path}/*.html"]
		files.each do |path|
			results_arr.push(calc_precision_recall_measure(path))
		end

		results_arr.each do |results|
			if results.precision == 0
				zero_p += 1
			end
			if results.recall == 0
				zero_r += 1
			end
			if results.f_measure == 0
				zero_f += 1
			end
			precision += results.precision
			recall += results.recall
			f_measure += results.f_measure
		end
		precision = precision / (results_arr.length - zero_p)
		recall = recall / (results_arr.length - zero_r)
		f_measure = f_measure / (results_arr.length - zero_f)

		puts "precision: #{precision}"
		puts "recall: #{recall}"
		puts "f-measure: #{f_measure}"
	end

	def calc_precision_recall_measure(path)
		extract_data = Extract_data.new
		dom_tree_extractor = Dom_tree_extractor.new
		info = extract_data.collect_data(path)
		dom_tree_info = dom_tree_extractor.extract_reject_long_strings(path)
		found = false
		relevants = check_relevants(info)
		retrieved = 0
		prec_rec_f = Prec_rec_f.new
		dom_tree_info.each do |dtinfo|
			if !info.edition.nil? && (dtinfo.to_s.include? info.edition.to_s)
	   	    	retrieved += 1
	   	    end
	   	    if !info.year.nil? && (dtinfo.to_s.include? info.year.to_s)
	   	    	retrieved += 1
	   	    end
	   	    if !info.language.nil? && (dtinfo.to_s.include? info.language.to_s)
	   	    	retrieved += 1
	   	    end
	   	    if !info.especifications.nil? && (dtinfo.to_s.include? info.especifications.to_s)
	   	    	retrieved += 1
	   	    end
	   	    if !info.dimensions.nil? && (dtinfo.to_s.include? info.dimensions.to_s)
	   	    	retrieved += 1
	   	    end
   	    	if !info.weight.nil? && (dtinfo.to_s.include? info.weight.to_s)
   	    		retrieved += 1
   	    	end 
   	    	if !info.isbn.nil? && (dtinfo.to_s.include? info.isbn.to_s)
   	    		retrieved += 1
   	    	end 
   	    	if !info.pages.nil? && (dtinfo.to_s.include? info.pages.to_s)
  				retrieved += 1
  			end 
  			if !info.publisher.nil? && (dtinfo.to_s.include? info.publisher.to_s)
  				retrieved += 1
  			end 
		end

		if retrieved == 0 || relevants == 0
			precision = 0
			recall = 0
			f_measure = 0
		else
			precision = relevants.to_f / retrieved
			recall = retrieved.to_f / relevants
			f_measure = (2 * precision.to_f * recall)/(precision.to_f + recall)
		end

		if precision > 1
			precision = 1
		end
		if recall > 1
			recall = 1
		end

		prec_rec_f.precision = precision
		prec_rec_f.recall = recall
		prec_rec_f.f_measure = f_measure

		prec_rec_f
	end

	def check_relevants(info)
		relevants = 9
		if !info.nil?
	  		if info.publisher.nil?
	  			relevants -= 1
	  		end
	  		if info.pages.nil?
	  			relevants -= 1
	  		end
	   	    if info.isbn.nil?
	   	    	relevants -= 1
	   	    end
	   	    if info.weight.nil?
	   	    	relevants -= 1
	   	    end
	   	    if info.dimensions.nil?
	   	    	relevants -= 1
	   	    end
	   	    if info.especifications.nil?
	   	    	relevants -= 1
	   	    end
	   	    if info.language.nil?
	   	    	relevants -= 1
	   	    end
	   	    if info.year.nil?
	   	    	relevants -= 1
	   	    end
	   	    if info.edition.nil?
	   	    	relevants -= 1
	   	    end
	   	end
	   	relevants
	end

end

class Prec_rec_f
	attr_accessor :precision
	attr_accessor :recall
	attr_accessor :f_measure
end