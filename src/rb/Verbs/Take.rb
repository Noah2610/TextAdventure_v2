class Verbs::Take < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return text 'not_found'  if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: :item, ignore: ignore
		return text 'not_found'  unless (word)
		if    (word.is_not? :item)
			## Is not Item
			return Verbs::Verb.substitute text('cannot_take'), word
		end

		## Is ITEM
		## Check if Item is already in Player's Inventory
		unless (PLAYER.has_item? word.instance)
			return Verbs::Verb.substitute text('took'), word  if (PLAYER.item_add word.instance)
			return Verbs::Verb.substitute text('cannot_take'), word
		else
			return Verbs::Verb.substitute text('in_inventory'), word
		end

	end
end
