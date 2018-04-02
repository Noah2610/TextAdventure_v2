
class Settings
	def initialize file
		## Validate file
		@CONTENT = Settings.validate_file file
		## Load initial settings from file
		@SETTINGS = init_settings
	end

	def Settings.validate_file file
		## Check that file exists
		abort [
			"#{__FILE__}: ERROR:",
			"  File '#{file}' doesn't exist or is a directory.",
			"  Exitting."
		].join("\n")  unless (File.file? file)

		## Check that file has proper extension
		unless (file =~ /\.(yml|yaml)\z/i)
			abort [
				"#{__FILE__}: ERROR:",
				"  File '#{file}' does not have a YAML extension.",
				"  If you still want to load it as YAML, use --force-yaml.",
				"  Exitting."
			].join("\n")
		end  unless (CL_ARGS[:options][:force_yaml])

		## Load yaml
		begin
			content = YAML.load_file file
		rescue
			# Couldn't parse yaml, abort with message
			abort [
				"#{__FILE__}: ERROR:",
				"  Coudln't parse YAML file 'file', check that it contains proper syntax.",
				"  Exitting."
			].join("\n")
		end

		## File should be valid at this point. Return file content
		return content
	end

	def init_settings
		settings = {}
		## Load all settings that aren't environment specific
		@CONTENT.each do |key, val|
			next  if (key =~ /environments?/i)
			settings[key.downcase.strip] = val
		end

		## Overwrite settings with environment specific settings
		if ( key_env = @CONTENT.map { |k,v| k  if (k =~ /environments?/i) } .reject { |x| x.nil? } .first )
			## Check if specific environment settings exist
			if (@CONTENT[key_env][ENVT.env])
				## Overwrite
				@CONTENT[key_env][ENVT.env].each do |key, val|
					settings[key.downcase.strip] = val
				end
			end
		end

		return settings
	end

	def logfile
		logdir = @SETTINGS['logdir']
		return nil  if (logdir.nil?)
		full_logdir = File.join(ROOT, logdir)
		## Create directory it if doesn't exist
		Dir.mkdir full_logdir  unless (File.directory? full_logdir)
		return File.join full_logdir, @SETTINGS['logfile']
	end

	def output
		return @SETTINGS['output'] || {}
	end

	def input
		return @SETTINGS['input'] || {}
	end

	def menu
		return @SETTINGS['menu']
	end

	def chain_keyword? string
		return false  unless (kws = @SETTINGS['chain_keywords'])
		kws.each do |kw|
			kwregex = kw.to_regex
			if (m = string.match(kwregex))
				ret = [m[0], string =~ kwregex]
				return ret
			end
		end
		return false
	end
end

