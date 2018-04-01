
## This module contains useful methods that can check strings (keywords) if they match another string
## It is used for Instances and Terms
## The only dependency on the class that includes this module,
## is that they provide a method 'keywords' that returns all available keywords as strings

module Keywords
	## Class that includes this module needs to overwrite this method!
	def keywords
		return nil
	end

	## Check if string matches a keyword
	## Return matched string and match position in string:
	#   return ['keyword', 0]
	def keyword? string
		return false  unless (kws = keywords)
		kws.each do |kw|
			kwregex = kw.to_regex
			if (m = string.match(kwregex))
				ret = [m[0], string =~ kwregex]
				return ret
			end
		end
		return false
	end
end

