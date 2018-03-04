
class Environment
	def initialize env, args = {}
		## Validate and set environment
		@ENV = Environment.validate_env env
	end

	def Environment.validate_env env
		ret = nil
		case env.downcase
		when :dev, :development, 'dev', 'development'
			ret = :development
		when :prod, :production, 'prod', 'production'
			ret = :production
		when :test, 'test'
			ret = :test
		else
			## Not a valid environment, abort
			abort [
				"#{__FILE__}: ERROR:",
				"  Environment '#{env.to_s}' is not valid.",
				"  Exitting."
			].join("\n")
		end
		return ret
	end

	def env
		return @ENV.to_s
	end

	def development?
		return @ENV == :development
	end
	def dev?
		return development?
	end

	def production?
		return @ENV == :production
	end
	def prod?
		return production?
	end

	def test?
		return @ENV == :test
	end

end

