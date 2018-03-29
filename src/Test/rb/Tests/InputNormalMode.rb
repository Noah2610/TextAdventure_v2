
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

		assert_equal 'Cornfield', PLAYER.current_room.get_classname, "Player should have gone to unknown Room: #{output}"
	end

	def test_goto_known_room
		reset
		@rooms[:Cornfield].known!

		output = process_line 'Go to Cornfield'

		assert_equal 'Cornfield', PLAYER.current_room.get_classname, "Player should have gone to known Room: #{output}"
	end

	## COMPONENTS ##
	def test_open_glove_compartment
		reset

		output = process_line 'Open this Glove Compartment'

		assert_equal true, @components[:GloveCompartment].is_open?, "Player should have opened Component: #{output}"
	end

	def test_close_glove_compartment
		reset
		@components[:GloveCompartment].open!

		output = process_line 'Close this Glove Compartment'

		assert_equal true, @components[:GloveCompartment].is_closed?, "Player should have closed Component: #{output}"
	end
end

