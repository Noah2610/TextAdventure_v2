
## Extend String with to_regex method to convert to regular expression properly, including options
class String
	def to_regex
		slashes = self.count '/'
		return Regexp.new(self)  if     (slashes == 0)
		return nil               unless (slashes == 2)
		split = self.split("/")
		options = (
			(split[2].include?("x") ? Regexp::EXTENDED : 0) |
			(split[2].include?("i") ? Regexp::IGNORECASE : 0) |
			(split[2].include?("m") ? Regexp::MULTILINE : 0)
		)              unless (split[2].nil?)
		options = nil  if (split[2].nil?)
		return Regexp.new(split[1], options)
	end
end

