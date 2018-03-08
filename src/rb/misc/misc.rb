
LOG_AP_OPTIONS = {
	indent: 2,
	plain:  true
}

### Misc methods
## Get current Curses screen size
def screen_size target = :all
	ret = nil
	case target
	when :width, :w
		ret = Curses.cols
	when :height, :h
		ret = Curses.lines
	when :all
		ret = {
			w: screen_size(:w),
			h: screen_size(:h)
		}
	end
	return ret
end

### Log, debug output
## USAGE:
## log 'message one', 'message two', ..., mode: ?w, ap: true
#      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^
#      Messages you want to have logged,  optional options
def log *args
	return nil  if (args.empty?)
	## Parse args to separate messages from options
	if (args.last.is_a?(Hash) && args.size > 1)
		opts = args.last
		msgs = args[0 ... -1]
	else
		opts = {}
		msgs = args
	end

	default_mode = ?a
	filepath = SETTINGS.logfile

	if (msgs.empty?)
		file = File.new filepath, ?w
		file.write ''
		file.close
		return
	end

	file = File.new filepath, opts[:mode] || default_mode
	msgs.each_with_index do |msg, index|
		m = msg.ai(LOG_AP_OPTIONS)  if (opts[:ap].nil? || opts[:ap] == true)
		m = msg                     if (opts[:ap] == false)
		file.write m + (index < msgs.size - 1 ? ?\t : '')
	end
	file.write "\n"
	file.close
	return msgs
end

## Clear log
log  if (ENVT.dev?)

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

