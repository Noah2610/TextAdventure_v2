### Auto-generated on 2018-04-01 by Noah.
class Verbs::Save < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		SAVEFILE.save!
		return '{COLOR:green}SAVED{RESET}'
	end
end
