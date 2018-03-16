
### Tests for user input in conversation mode

class TestInputConversationMode < MiniTest::Test
	include TestInputHelpers

	def reset args = {}
		super
		PLAYER.talk_to @persons[:Parsley]  unless (args[:no_talk] == true)
	end

	def test_talk_to_unknown_person
		reset no_talk: true

		output = process_line 'Talk to Unknown Person'

		assert_equal :conversation, PLAYER.mode, "Player should talk to unknown Person: #{output}"
	end

	def test_talk_to_known_person
		reset no_talk: true
		@persons[:Parsley].known!

		output = process_line 'Talk to Parsley'

		assert_equal :conversation, PLAYER.mode, "Player should talk to known Person: #{output}"
	end

	def test_leave_conversation
		reset

		output = process_line 'Good Bye friend!'
		$game_loop += 1
		$game.handle_queue

		assert_equal :normal, PLAYER.mode, "Player should have left conversation mode: #{output}"
	end

	def test_give_item_to_person
		reset
		item = @items[:Apple]
		PLAYER.item_add item

		output = process_line 'Take this Apple, friend!'

		assert_equal false, PLAYER.has_item?(item),            "Player should not have Item anymore: #{output}"
		assert_equal true, @persons[:Parsley].has_item?(item), "Player should have given Item to Person #{output}"
	end
end

