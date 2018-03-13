class Verbs::Take < Verbs::Verb
	def initialize args = {}
		super
	end

	def action args = {}
		return nil               if (args[:line].nil? || args[:word].nil?)
		word = args[:line].next_word pos: args[:word].position, priority: :item, ignore: ignore
		return text 'not_found'  unless (word)
		if    (word.is_not? :item)
			## Is not Item
			return text 'cannot_take', word
		end

		## Is ITEM
		## Check if Item is already in Player's Inventory
		unless (PLAYER.has_item? word.instance)
			return text 'took', word  if (PLAYER.item_add word.instance)
			return text 'cannot_take', word
		else
			return text 'in_inventory', word
		end

	end
end
