
### Tests for user input in normal mode

class TestInputNormalMode < MiniTest::Test
	include TestInputHelpers

	## ITEMS ##
	def test_take_unknown_item
		reset

		output = process_line 'Take this Red Ball'

		assert_equal true, PLAYER.has_item?(@items[:Apple]), "Player should have taken Item: #{output}"
	end

	def test_take_known_item
		reset
		@items[:Apple].known!

		output = process_line 'Take this Apple'

		assert_equal true, PLAYER.has_item?(@items[:Apple]), "Player should have taken known Item: #{output}"
	end

	## ROOMS ##
	def test_goto_unknown_room
		reset

		output = process_line 'Go to Dark Field'

		assert_equal 'Cornfield', PLAYER.current_room.get_instance_type_and_class[1], "Player should have gone to unknown Room: #{output}"
	end

	def test_goto_known_room
		reset
		@rooms[:Cornfield].known!

		output = process_line 'Go to Cornfield'

		assert_equal 'Cornfield', PLAYER.current_room.get_instance_type_and_class[1], "Player should have gone to known Room: #{output}"
	end
end

