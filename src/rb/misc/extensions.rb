
## Extend String with to_regex method to convert to regular expression properly, including options
class String
	def to_regex
		slashes = self.count '/'
		return /\A#{Regexp.quote self}\z/  if     (slashes < 2)
		return nil                         unless (self =~ /\A\/.+\/\z/)
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

