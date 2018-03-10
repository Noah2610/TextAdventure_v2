
## Extend String with to_regex method to convert to regular expression properly, including options
class String
	def to_regex args = {}
		slashes = self.count '/'
		if     (slashes < 2)
			if (args[:case_insensitive])
				return /\A#{Regexp.quote self}\z/i
			else
				return /\A#{Regexp.quote self}\z/
			end
		end
		return nil                         unless (self =~ /\A\/.+\/[xim]*\z/)
		string, options_str = self.match(/\A\/(.+)\/(.?+)\z/).to_a[1 .. -1]
		options = (
			(options_str.include?(?x) ? Regexp::EXTENDED   : 0) |
			(options_str.include?(?i) ? Regexp::IGNORECASE : 0) |
			(options_str.include?(?m) ? Regexp::MULTILINE  : 0)
		)
		options = nil  if (options == 0)
		return Regexp.new(string, options)
	end
end

