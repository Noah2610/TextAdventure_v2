### Auto-generated on 2018-03-13 by Noah Rosenzweig.
class Verbs::Test < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil               if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: nil, ignore: ignore
		return text 'not_found'  unless (word)
	end
end
