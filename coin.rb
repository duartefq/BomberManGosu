class Coin
	attr_accessor :coletado
	def initialize(window, x, y)
		@sprite = Gosu::Image.load_tiles(window, "img/power_up/coin.png", 60, 60, true)
		@x = x * 60
		@y = y * 60

		@item_get = Gosu::Sample.new(window, "music/system/item_get.wav")
		@tocou = false
		@sprite_atual = 0
		@coletado = false
	end

	def update
		if ( (Gosu::milliseconds % 5).zero? )
			@sprite_atual = (@sprite_atual < 7)?(@sprite_atual + 1):0
		end

		if (@coletado and not @tocou)
			@item_get.play
			@tocou = true
		end
	end

	def coletado? (x_player, y_player)
		if ( (Gosu::distance(@x, @y, x_player, y_player)) < 58 )
			@coletado = true
			return true
		end
	end

	def draw
		@sprite[@sprite_atual].draw(@x, @y, 2) if (not @coletado)
	end
end
