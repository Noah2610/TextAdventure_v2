#!/bin/env ruby

### Generate a new Instance .yml file in proper directory with the default file contents.

#TODO: Add RoomObject

require 'pathname'
## Root directory of project
ROOT = File.dirname(Pathname.new(File.join(File.absolute_path(__FILE__), '..')).realpath)
## Directories for files
DIR = {
	src: {
		verb:   File.join(ROOT, 'src/rb/Verbs'),
		item:   File.join(ROOT, 'src/rb/Instances/Items'),
		person: File.join(ROOT, 'src/rb/Instances/Persons'),
		room:   File.join(ROOT, 'src/rb/Instances/Rooms')
	},
	data: {
		verb:   File.join(ROOT, 'src/Data/Verbs'),
		item:   File.join(ROOT, 'src/Data/Items'),
		person: File.join(ROOT, 'src/Data/Persons'),
		room:   File.join(ROOT, 'src/Data/Rooms')
	}
}

# https://github.com/Noah2610/ArgumentParser
if (Gem::Specification.find_all_by_name('argument_parser').any?)
	require 'argument_parser'
else
	gem_path = File.join ROOT, 'lib/argument_parser.rb'
	if (File.file? gem_path)
		require gem_path
	else
		abort [
			"ERROR:",
			"  ArgumentParser gem not found, please run 'bin/get_argument_parser.sh' or './TA.rb'",
			"  to download it automatically into ./lib/",
			"ABORTING"
		].join("\n")
	end
end

USAGE = [
	"#{__FILE__}",
	"  DESCRIPTION",
	"    This is a helper script to easily create new Instance files for the game.",
	"    It will create properly named Ruby (.rb) and configuration (.yml) files",
	"    in their proper locations.",
	"",
	"  SYNOPSIS",
	"    #{__FILE__} [OPTIONS] TYPE NAME",
	"",
	"    TYPE",
	"      The Instance type to be created. Currently available:",
	"        'verb', 'item', 'person', 'room'",
	"      You can also use the first letter of each keyword:",
	"        'v', 'i', 'p', and 'r', respectively.",
	"      Note that input is case-sensitive.",
	"    NAME",
	"      The name of the new Instance.",
	"      This name will be used for filenames and classes.",
	"",
	"    OPTIONS",
	"      --help -h",
	"        Show this usage message.",
	"      --force -f",
	"        Overwrite files if they exist already."
].join("\n")

VALID_ARGUMENTS = {
	single: {
		help:   [[?h],      false],
		force:  [[?f],      false]
	},
	double: {
		help:   [['help'],  false],
		force:  [['force'], false]
	},
	keywords: {
		verb:   [['verb',   ?v], :INPUT],
		item:   [['item',   ?i], :INPUT],
		person: [['person', ?p], :INPUT],
		room:   [['room',   ?r], :INPUT]
	}
}

ARGUMENTS = ArgumentParser.get_arguments VALID_ARGUMENTS

## Help / Usage text
if (ARGUMENTS[:options][:help])
	puts USAGE
	exit
end

abort [
	"ERROR:",
	"  You must supply TWO arguments for this script to do anything.",
	"  See --help or -h for a list of available arguments.",
	"ABORTING"
].join("\n")  if (ARGUMENTS[:keywords].empty? || ARGUMENTS[:keywords].first.last.size < 2)

def check_file file
	if (File.file?(file))
		## File exists, abort
		abort [
			"ERROR:",
			"  File '#{file}' already exists.",
			"  Use --force or -f to overwrite file.",
			"ABORTING"
		].join("\n")  unless (ARGUMENTS[:options][:force])

		## Print warning
		puts [
			"Warning:",
			"  File '#{file}' exists, overwriting file."
		].join("\n")
	end
end

## Instance type
name_match = ARGUMENTS[:keywords].first.last.last.match(/\A([A-Za-z0-9]+)\z/)
abort [
	"ERROR:",
	"  Name '#{ARGUMENTS[:keywords].first.last.last}' is invalid. Exitting.",
	"  Valid characters: A-Z, a-z, 0-9",
	"ABORTING"
].join("\n")  if (name_match.nil?)

name = name_match[1]
name[0] = name[0].upcase
date = Time.now.strftime "%Y-%m-%d"
username = `git config user.name`.strip

case ARGUMENTS[:keywords].keys.first
when :verb
	#### VERB
	### CODE FILE
	codefile = File.join DIR[:src][:verb], "#{name}.rb"
	check_file codefile
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		"class Verbs::#{name} < Verbs::Verb",
		"	def initialize args = {}",
		"		super",
		"	end",
		"",
		"	def action args = {}",
		"		return nil               if (args[:line].nil? || args[:word].nil?)",
		"		word = args[:line].next_word pos: args[:word].position, priority: nil, ignore: ignore",
		"		return text 'not_found'  unless (word)",
		"	end",
		"end"
	].join("\n")
	puts [
		"Writing Verb template code to file:",
		"  '#{codefile}'"
	].join("\n")
	## Write to file
	f = File.open codefile, ?w
	f.write content
	f.close

	### CONFIGURATION FILE
	configfile = File.join DIR[:data][:verb], "#{name}.yml"
	check_file configfile
	templatefile = File.join DIR[:data][:verb], 'Verb.yml'
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		File.read(templatefile)
	].join("\n")
	puts [
		"Writing Verb default configuration to file:",
		"  '#{configfile}'"
	].join("\n")
	## Write to file
	f = File.open configfile, ?w
	f.write content
	f.close

when :item
	#### ITEM
	### CODE FILE
	codefile = File.join DIR[:src][:item], "#{name}.rb"
	check_file codefile
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		"class Instances::Items::#{name} < Instances::Items::Item",
		"	def initialize args = {}",
		"		super",
		"	end",
		"end"
	].join("\n")
	puts [
		"Writing Item template code to file:",
		"  '#{codefile}'"
	].join("\n")
	## Write to file
	f = File.open codefile, ?w
	f.write content
	f.close

	### CONFIGURATION FILE
	configfile = File.join DIR[:data][:item], "#{name}.yml"
	check_file configfile
	templatefile = File.join DIR[:data][:item], 'Item.yml'
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		File.read(templatefile)
	].join("\n")
	puts [
		"Writing Item default configuration to file:",
		"  '#{configfile}'"
	].join("\n")
	## Write to file
	f = File.open configfile, ?w
	f.write content
	f.close

when :person
	#### PERSON
	### CODE FILE
	codefile = File.join DIR[:src][:person], "#{name}.rb"
	check_file codefile
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		"class Instances::Persons::#{name} < Instances::Persons::Person",
		"	def initialize args = {}",
		"		super",
		"	end",
		"end"
	].join("\n")
	puts [
		"Writing Person template code to file:",
		"  '#{codefile}'"
	].join("\n")
	## Write to file
	f = File.open codefile, ?w
	f.write content
	f.close

	### CONFIGURATION FILE
	configfile = File.join DIR[:data][:person], "#{name}.yml"
	check_file configfile
	templatefile = File.join DIR[:data][:person], 'Person.yml'
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		File.read(templatefile)
	].join("\n")
	puts [
		"Writing Person default configuration to file:",
		"  '#{configfile}'"
	].join("\n")
	## Write to file
	f = File.open configfile, ?w
	f.write content
	f.close

when :room
	#### ROOM
	### CODE FILE
	codefile = File.join DIR[:src][:room], "#{name}.rb"
	check_file codefile
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		"class Instances::Rooms::#{name} < Instances::Rooms::Room",
		"	def initialize args = {}",
		"		super",
		"	end",
		"end"
	].join("\n")
	puts [
		"Writing Room template code to file:",
		"  '#{codefile}'"
	].join("\n")
	## Write to file
	f = File.open codefile, ?w
	f.write content
	f.close

	### CONFIGURATION FILE
	configfile = File.join DIR[:data][:room], "#{name}.yml"
	check_file configfile
	templatefile = File.join DIR[:data][:room], 'Room.yml'
	## Ruby file content
	content = [
		"### Auto-generated on #{date} by #{username}.",
		File.read(templatefile)
	].join("\n")
	puts [
		"Writing Room default configuration to file:",
		"  '#{configfile}'"
	].join("\n")
	## Write to file
	f = File.open configfile, ?w
	f.write content
	f.close

end

puts "GENERATED FILES"

