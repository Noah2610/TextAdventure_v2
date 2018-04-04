
### Savefile saving and restoring tests

class TestSavefile < MiniTest::Test
	include TestInputHelpers

	def setup
		super
		@savefile = Saves::Savefile.new 'test_permanent'
	end

	def test_restore_savefile
		reset

		@savefile.restore

		assert_equal('Cornfield', PLAYER.current_room.get_classname,
								 'Restore Savefile: Player should be in Cornfield')
		assert_equal(true,        PLAYER.current_room.known?,
								 'Restore Savefile: Cornfield should be known')
		assert_equal(true,        PLAYER.has_item?(:Apple),
								 'Restore Savefile: Player should have Apple')
		assert_equal(false,       @rooms[:ParsleysTruck].has_item?(:Apple),
								 'Restore Savefile: ParsleysTruck should not have Apple')
		assert_equal(true, @rooms[:ParsleysTruck].components.first.is_open?,
								 'Restore Savefile: GloveCompartment should be open')
	end

	def test_save_then_restore_savefile
		reset
		@savefile.restore
		savefile = Saves::Savefile.new 'test_temporary'
		process_line 'go to Parsleys Truck'
		process_line 'take Joint'
		process_line 'close Glove Compartment'
		process_line 'talk to Parsley'
		process_line 'take Apple'
		process_line 'bye'

		savefile.save!
		savefile.restore

		assert_equal('ParsleysTruck', PLAYER.current_room.get_classname,
								 'Save & Restore Savefile: Player should be in ParsleysTruck')
		assert_equal(true,            PLAYER.has_item?(:Joint),
								 'Save & Restore Savefile: Player should have Joint')
		assert_equal(false,           PLAYER.has_item?(:Apple),
								 'Save & Restore Savefile: Player should not have Apple')
		assert_equal(false,           @rooms[:ParsleysTruck].has_item?(:Apple),
								 'Save & Restore Savefile: ParsleysTruck should not have Apple')
		assert_equal(true,            @rooms[:ParsleysTruck].persons.first.has_item?(:Apple),
								 'Save & Restore Savefile: Parsley should have Apple')
		assert_equal(true,            @rooms[:ParsleysTruck].components.first.is_closed?,
								 'Save & Restore Savefile: GloveCompartment should be closed')
	end
end

