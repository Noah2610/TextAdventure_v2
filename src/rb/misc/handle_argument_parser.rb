
## Require my ArgumentParser gem or download if not installed
#  https://github.com/Noah2610/ArgumentParser
if (Gem::Specification.find_all_by_name('argument_parser').any?)
	require 'argument_parser'
else
	get_argumentparser_script = File.join ROOT, 'bin/get_argument_parser.sh'
	argumentparser_dir = File.join ROOT, 'lib'
	Dir.mkdir argumentparser_dir  unless (File.directory? argumentparser_dir)
	argumentparser_file = File.join argumentparser_dir, 'argument_parser.rb'
	# Output message to terminal
	puts [
		"#{__FILE__}:",
		"  Executing shell script #{get_argumentparser_script}."
	].join("\n")
	# Execute shell script
	ret = system "#{get_argumentparser_script} #{argumentparser_file}"
	if (!!ret)
		require argumentparser_file
	else
		abort "#{__FILE__}: Error:\n  Shell script exited with error; exitting."
	end
end

## Define valid command-line arguments for ArgumentParser
VALID_ARGUMENTS = {
	single: {
		help:     [['h'],                  false],
		version:  [['v'],                  false],
		env:      [['e'],                  true]
	},
	double: {
		help:     [['help'],               false],
		version:  [['version'],            false],
		env:      [['env','environment'],  true]
	}
}

## Set help and version text
HELP_TXT    = "TextAdventure v2!\nHelp text coming soon..."
VERSION_TXT = "TextAdventure 2.0"

## Process command-line arguments
CL_ARGS = ArgumentParser.get_arguments VALID_ARGUMENTS

## Handle help and version arguments
if    (CL_ARGS[:options][:help])
	puts HELP_TXT
	exit
elsif (CL_ARGS[:options][:version])
	puts VERSION_TXT
	exit
end

