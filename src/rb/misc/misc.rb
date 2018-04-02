
LOG_AP_OPTIONS = {
	indent: 2,
	plain:  true
}
LOG_METHOD_OPTIONS = [
	:ap
]

### Misc methods
## Log, debug output
## USAGE:
## log 'message one', 'message two', ..., mode: ?w, ap: true
#      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^
#      Messages you want to have logged,  optional options
def log *args
	return nil  if (args.empty?)
	## Parse args to separate messages from options
	opts = {}
	msgs = []
	if (args.last.is_a?(Hash) && args.size > 1)
		# Check if Hash contains any pre-defined option, if not then handle Hash as message
		if ((args.last.keys & LOG_METHOD_OPTIONS).any?)
			opts = args.last
			msgs = args[0 ... -1]
		else
			msgs = args[0 .. -1]
		end
	else
		msgs = args
	end

	default_mode = ?a
	filepath = SETTINGS.logfile

	file = File.new filepath, opts[:mode] || default_mode
	# Print tick
	msgs.each_with_index do |msg, index|
		unless (ENVT.prod? || ENVT.test?)
			m = msg.ai(LOG_AP_OPTIONS)  if (opts[:ap].nil? || opts[:ap] == true)
			m = msg.to_s                if (opts[:ap] == false)
		else
			m = msg.to_s
		end
		file.write m + (index < msgs.size - 1 ? ?\t : '')
	end
	file.write "\n"
	file.close
	return msgs
end

## Clear log
def clear_log
	f = File.new SETTINGS.logfile, ?w
	f.write ''
	f.close
end

## Clear log
clear_log  unless (ENVT.prod?)

## Close Curses screen and start Byebug debugger
## Usage: debug.call
def debug
	Curses.close_screen
	return method(:debugger)
end
alias :dbg :debug

## Require multiple files from directory
def require_files dir, args = {}
	return nil  unless (File.directory? dir)
	except = args[:except] ? [args[:except]].flatten : []
	Dir.new(dir).each do |file|
		next  if (file =~ /\A\.{1,2}\z/ || !(file =~ /\A.+\.rb\z/))
		filepath = File.join dir, file
		next  if (except.any? { |e| (file =~ /\A#{Regexp.quote e}(\.rb)?\z/ || filepath =~ /\A#{Regexp.quote e}(\.rb)?\z/) })
		require filepath
	end
end

## Read YAML file content and return
def read_yaml file
	return nil  unless (File.file? file)
	return YAML.load_file file
end

## Sort a Hash by its key names in the order of given Array
def sort_hash hash, args
	sort_by = args[:by]
	return nil  unless (args.is_a?(Hash) && args.key?(:by) && args[:by].is_a?(Array))
	return hash.sort do |item_a, item_b|
		index_a = sort_by.index(item_a.first) || 0
		index_b = sort_by.index(item_b.first) || 0
		next index_a - index_b
	end .to_h
end

