class Stock 
	attr_accessor :key, :value

	def initialize(key ,value)
		@key   = key
		@value = value
	end

	def <=>(o)
		self.key <=> o.key
	end
end

