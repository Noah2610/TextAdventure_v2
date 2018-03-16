
class TestInput < MiniTest::Test
	def setup
		@rooms = {
			ParsleysTruck: Instances::Rooms::ROOMS[:ParsleysTruck],
			Cornfield:     Instances::Rooms::ROOMS[:Cornfield]
		}
	end

	def test_go_to_rooms
		@rooms[:ParsleysTruck].unknown!
		@rooms[:Cornfield].unknown!
		PLAYER.goto! @rooms[:ParsleysTruck]
		line = Input::Line.new "go to #{@rooms.keys[1]}"
		output = line.process
		assert_equal @rooms.keys[0].to_s, PLAYER.current_room.get_instance_type_and_class[1], "Player should not have gone to Cornfield: #{output}"
		line = Input::Line.new "go outside"
		output = line.process
		assert_equal @rooms.keys[1].to_s, PLAYER.current_room.get_instance_type_and_class[1], "Player should have gone outside: #{output}"
		line = Input::Line.new "go inside"
		output = line.process
		assert_equal @rooms.keys[0].to_s, PLAYER.current_room.get_instance_type_and_class[1], "Player should have gone inside: #{output}"
	end

	def test_take_item
		PLAYER.goto! @rooms[:ParsleysTruck]
		item = :Apple
		assert_equal false, PLAYER.has_item?(item), 'Player should not have Item'
		line = Input::Line.new "take #{item.to_s}"
		output = line.process
		assert_equal true, PLAYER.has_item?(item), "Player should have taken Item: #{output}"
	end

	def test_conversation_give_item
		PLAYER.goto! @rooms[:ParsleysTruck]
		item = Instances::Items::Apple.new
		PLAYER.item_add item
		person = PLAYER.current_room.persons.first
		line = Input::Line.new "talk to Parsley"
		output = line.process
		assert_equal true, PLAYER.mode?(:conversation), "Player should be in conversation mode: #{output}"
		line = Input::Line.new "Hey bro, take this apple, will ya?"
		output = line.process
		assert_equal false, PLAYER.has_item?(item), "Player should not have Item anymore: #{output}"
		assert_equal true, person.has_item?(item), "Player should have given Item to Person: #{output}"
		line = Input::Line.new "Bye buddy! See ya around!"
		output = line.process
		## Increase game_loop tick by one and handle queues
		$game_loop += 1
		$game.handle_queue
		assert_equal true, PLAYER.mode?(:normal), "Player should have exitted conversation: #{output}"
	end
end

