
### Misc constants
AP_OPTIONS = {
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

## Log, debug output
def log msg = nil, mode = 'a'
	case Env
	when 'dev'
		filepath = File.join(DIR[:log], 'dev.log')
	else
		return nil
	end

	if (msg.nil?)
		file = File.new filepath, 'w'
		file.write ''
		file.close
		return msg
	end

	file = File.new filepath, mode
	msg = msg.ai AP_OPTIONS
	file.write msg + "\n"
	file.close
	return msg
end

## Clear log
log  if (Env == 'dev')

