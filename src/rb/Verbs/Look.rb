
class Verbs::Look < Verbs::Verb
	def initialize args = {}
		super
	end

	def action
		return @data['default_text']
	end
end

