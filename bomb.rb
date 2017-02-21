class Bomba
	attr_reader :actived, :explodiu
	
	def initialize(window, time, map, taxa, player)
		@window = window
		@sprite_bomb = Gosu::Image.load_tiles(@window, "img/player/sprite_bombas.png", 60, 60, true)
		@count_bomb = 0
		@time_bomba = 0

		@sprite_explosao = Gosu::Image.load_tiles(window, "img/player/sprite_explosao.png", 60, 60, true)
		@count_sprite_explosao = 0
		
		@x = player.x
		@y = player.y
		
		# Tempo atual + Tempo até explodir
		@start = (Gosu::milliseconds / 1000) + time
		
		@map = map
		@taxa = taxa # Expansão da Bomba (Potência)
		@player = player

		@explodiu = false
		@actived = true
		@area = []
		
		@miso_bon_sound = Gosu::Sample.new(@window, "music/system/miso_bon.wav")
	end
	
	def update
		tempo_atual = Gosu::milliseconds / 1000

		if ( (Gosu::milliseconds % 5).zero? )
			@count_bomb = (@count_bomb < 2)?(@count_bomb + 1):0
		end
	  
		if @actived # Bomba lançada?
			if ( (tempo_atual >= @start) and not @explodiu ) # Hora de explodir?
				#puts "BOOM!"
				@explodiu = true
				# puts "x: #{@x/60} y: #{@y/60}"
				@area = @map.explod( @x / 60, @y / 60, @taxa ) #Mapa, Posicao bomba (x e y), taxa de expansão
				#puts "Pos player: x: #{@player.x/60} y: #{@player.y/60}"
				#puts "Pos bomba: x: #{@x/60} y: #{@y/60}"
				if (@area.include? [@player.x/60, @player.y/60]) # Verifica se morreu
					@player.morreu = true
				end
			elsif (not @explodiu)
				#puts tempo_atual
			end
		end
	  
	  	if ( @explodiu )
	  		if (Gosu::milliseconds > @time_bomba)
	  			if (@count_sprite_explosao.zero?)
	  				@miso_bon_sound.play
	  			end
		  		if (@count_sprite_explosao < 4)
		        	@count_sprite_explosao += 1
		        else
		        	@count_sprite_explosao = 0
		        	limpar
		        end
		        @time_bomba = Gosu::milliseconds + 100
	    	end
	  	end
		# if ( (@explodiu) and (tempo_atual >= (@start + 0.5) ) )
		# 	limpar # Já explodiu, hora de limpar o fogo do mapa e o player já pode soltar bomba de novo.
		# end
	end
	
	def limpar
		@map.limpar
		@explodiu = false
		@actived = false
		@area = []
	end
	
	
	def draw
		if @actived then
			if (not @explodiu)
				@sprite_bomb[@count_bomb].draw(@x, @y, 2)
			end
		end

		if (@explodiu)
			for posicao in @area do
				@sprite_explosao[@count_sprite_explosao].draw(posicao[0]*60, posicao[1]*60, 3)
			end
		end
	end
end
