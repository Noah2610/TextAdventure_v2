
## The Player is supposed to have an Inventory
## and keep track of where the user is and what they can do
## Get available Instances, ...

class Player
	include Inventory

	def initialize args = {}
		## Init Inventory
		super

		#TODO:
		## Read savefile content

		## Current Room
		@room = nil

		## Interaction mode, available:
		#   :normal       - normal mode, use Verbs to interact with anything
		#   :conversation - in conversation with Person
		@mode = :normal

		## Person Player is in conversation with, used for conversation mode
		@talking_to = nil
	end

	def name
		#TODO: Get name from savefile
		return '{COLOR:red;ATTR:bold,standout}Player{RESET}'
	end

	## is? method for some compatibility with methods used on Instances (kinda hacky)
	def is? target
		return target.downcase.to_sym == :player
	end

	## Return current mode
	def mode
		return @mode
	end

	## Check current mode
	def mode? target
		return @mode == target
	end

	## Check if in conversation with Person
	def in_conversation? person = nil
		return mode? :conversation  if (person.nil?)
		return @in_conversation     if (person && person.is?(:person) && mode?(:conversation))
		return nil
	end

	## Return current Room
	def current_room
		return @room
	end

	## Add Item to Inventory; super actually adds it
	def item_add item
		ret = super
		item.known!  if (ret)
		return ret
	end

	## Goto other Room; Check if that's possible first
	def goto room, args = {}
		return false  unless (args[:force] || current_room.can_goto?(room))
		if    (room.is_a? Instances::Rooms::Room)
			@room = room
		elsif (room.is_a? Class)
			@room = Instances::Rooms::ROOMS.values.map { |r| r  if (r.is_a? room) } .reject { |x| !x } .first
		elsif (room.is_a?(Symbol) || room.is_a?(String))
			@room = Instances::Rooms::ROOMS[room.to_sym]
		end
		@room.went!  unless (@room.nil?)
		return @room
	end

	## Force goto Room
	def goto! room
		return goto room, force: true
	end

	## Return available Verbs (usually all Verbs)
	def available_verbs
		return Verbs::VERBS.values
	end

	## Return available Terms
	def available_terms
		return nil  unless (mode? :conversation)
		return conversation_person.terms
	end

	## Return all currently available Instances
	def available_instances
		ret = {}
		components = current_room.components || []
		## Items
		ret[:items]      = [items, current_room.items, components.map { |c| c.items }] .flatten.reject { |i| !i }
		## Components
		ret[:components] = [components]                                                .flatten.reject { |i| !i }
		## Persons
		ret[:persons]    = [current_room.persons]                                      .flatten.reject { |i| !i }
		## Rooms
		ret[:rooms]      = [current_room, current_room.get_neighbors]                  .flatten.reject { |i| !i }
		return ret
	end

	## Return available Room Events of current_room
	def available_events
		return current_room.events || []
	end

	## Enter conversation mode with Person
	def conversation_start person
		return nil  if (person.is_not? :person)
		@mode = :conversation
		@talking_to = person
		$game.window(:conversation).show
		$game.window(:input).prompt = :conversation
	end

	## Leave conversation
	def conversation_end args = {}
		return nil  unless (mode? :conversation)
		conversation_person.conversation_end
		@mode = :normal
		@talking_to = nil
		unless (args[:keep_window])
			$game.window(:conversation).hide
			$game.window(:conversation).clear
		else
			$game.queue 1, $game.window(:conversation), :hide
			$game.queue 1, $game.window(:conversation), :clear
		end
		$game.window(:input).prompt = :normal
	end

	## Person Player is talking to
	def conversation_person
		return nil  unless (mode? :conversation)
		return @talking_to
	end

	## Conversation methods aliases
	alias :talk_to    :conversation_start
	alias :talk_end   :conversation_end
	alias :talking_to :conversation_person

end

