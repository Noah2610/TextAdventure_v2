
module Instances
	module Items
		## Read all item data files and return them
		## Necessary for getting the keywords for items
		def self.load_item_data
			return ( self.constants.map do |classname|
				data = read_data(File.join(DIR[:data][:items], "#{classname.to_s}.yml"))
				next [classname, data]  unless (data.nil?)
			end .reject { |x| !x } .to_h )
		end

		def self.read_data file
			return nil  unless (File.file? file)
			return YAML.load_file file
		end

		class Item < Instance
			def initialize args = {}
				super
				@data = ITEM_DATA[self.class.name.sub('Instances::Items::','').to_sym]
			end
		end
	end
end

