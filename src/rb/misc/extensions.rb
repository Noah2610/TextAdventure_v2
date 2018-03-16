
## Extend String with to_regex method to convert to regular expression properly, including options
class String
	def to_regex args = {}
		slashes = self.count '/'
		if     (slashes < 2)
			if (args[:case_sensitive])
				#return /#{args[:word] ? '\b' : '\A'}#{Regexp.quote self}#{args[:word] ? '\b' : '\z'}/
				return /\b#{Regexp.quote self}\b/
			else
				#return /#{args[:word] ? '\b' : '\A'}#{Regexp.quote self}#{args[:word] ? '\b' : '\z'}/i
				return /\b#{Regexp.quote self}\b/i
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

