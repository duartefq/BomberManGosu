class Map
	attr_accessor :especiais, :especiais_ativos
	attr_reader :tiles
	def initialize(window, filename, especiais)
		@tileset = Gosu::Image.load_tiles(window, "img/stage/tile.png", 60, 60, true)
		# @sprite_explosao = Gosu::Image.load_tiles(window, "img/player/sprite_explosao.png", 60, 60, true)
		# @count_sprite_explosao = 0
		@graficos_especiais = Gosu::Image.load_tiles(window, "img/power_up/especiais.png", 60, 60, true)

		lines = File.readlines(filename).map { |line| line.chomp }

    	@boxs = []
    	
    	@lista_especiais = especiais
    	@especiais = {}
    	@especiais_ativos = {}

    	@special_sound = Gosu::Sample.new(window, "music/system/b_special.wav")

		@height = lines.size # Altura (oh rly?)
		@width = lines[0].size # Largura (oh rly?)

		@coins = []
    	@tiles = Array.new(@width) do |x|
	      	Array.new(@height) do |y|
	        	case lines[y][x, 1]
		        	when '#' 
		          		0 # Parede indestrutível
		        	when 'o'
		          		1 # Parede destrutível
		          		#@boxs.push() #Inicializa caixa (classe box, pos.x, pos.y...)
		        	when 'e'
		          		2 # Especial
		          		@especiais.store([x,y],@lista_especiais.pop)
	        		when '-'
	        			3 # Espaço livre
	        		when 'c' 
	        			5 # Coin
	        			# @coins.push(Coin.new(window, x, y))
	        		else
	          			nil
        		end
      		end
    	end

    	for i in 0...@tiles.size do 
    		for j in 0...@tiles[i].size do 
    			if (@tiles[i][j] == 5) then
    				@coins.push(Coin.new(window, i, j))
    			end
    		end
    	end
	end

	def draw
		@width.times do |x|
      		@height.times do |y|
	        	tile = @tiles[x][y]
	        	if ( tile == 0 )
	        		@tileset[1].draw(x*60, y*60, 2)
	        	elsif ( tile == 1 )
	        		@tileset[0].draw(x*60, y*60, 2)
	        	elsif ( ( tile == 2 ) and not @especiais_ativos.include?([x,y]))
	        		# puts "Desenhando pedra em #{x} e #{y}"
	        		@tileset[0].draw(x*60, y*60, 3)
				elsif ( tile == 4 )
	        		
        			# if (@count_sprite_explosao < 4)
        			# 	@sprite_explosao[0].draw(x*60, y*60, 3)
        			# 	@count_sprite_explosao += 1
        			# else
        			# 	@count_sprite_explosao = 0
        			# 	limpar
        			# end
	        		
	        	end
	        end
        end

        if ( not @especiais_ativos.empty? )
        	@especiais_ativos.each { |key,value|
        		@graficos_especiais[value].draw(key[0]*60, key[1]*60, 2)
        	}
        end

        if (not @coins.empty?)
	        for c in @coins
	        	c.draw
	        end
	    end

        #puts "x: #{@especiais[[2,6]]}"
    end

    def update
    	if (!@coins.empty?)
	    	for c in @coins
	        	c.update
	        end
	    end
    end
    
	def limpar()
		for x in 0...@tiles.size
			for y in 0...@tiles[x].size
				if (@tiles[x][y] == 4) then
					@tiles[x][y] = 3
				end
			end
		end
	end

	# Testa se o lugar ao qual algo/alguém quer se movimentar está livre.
	# Em construção.
	# dir (1 = y, 0 = x), move 
	def move_possivel ( x, y, dir, move )

		# Casos Especiais
		return false if ( (x == 0) and ( ( move < 0) and dir.zero? ) )
		return false if ( (x == ( (@width * 60) - 60)) and (move > 0) and dir.zero? )
		return false if ( (y == 0) and (move < 0) and (dir == 1) )

		# Funciona:
		if ( (dir == 1) and (((y + move) % 60) == 1) )
			return ( (@tiles[ x/60 ][(y /60)+ move ] == 3) or (@tiles[ x/60 ][(y /60)+ move ] == 5) )
		elsif ( (dir == 0) and (((x + move) % 60) == 1) )
			return ( (@tiles[ (x /60)+ move ][ y /60 ] == 3) or (@tiles[ (x /60)+ move ][ y /60 ] == 5) )
		else			
			return ( (@tiles[ (x + ( (dir == 0)?move:0 ))/60 ][(y + ( (dir == 0)?0:move))/60 ] == 3) or (@tiles[ (x + ( (dir == 0)?move:0 ))/60 ][(y + ( (dir == 0)?0:move))/60 ] == 5) )
		end
	end

	def pegou_coin? ( x_player, y_player ) 
		retorno = false # Pegou nada
		if (not @coins.empty?) 
			for c in @coins
				if c.coletado?(x_player, y_player)
					retorno = true # Pegou coin
				end
			end
		end
		return retorno
	end

	def pegou_tudo? () 
		return @coins.select {|c| (not c.coletado )}.empty?
	end

	def pegou_especial?( x_player, y_player )
		# especiais_coletados = []
		especial_coletado = -1
		if (not @especiais_ativos.empty?)
			@especiais_ativos.each { |key,value|
				# puts "X Key: #{key[0]} Y Key: #{key[1]}\nX Player: #{x_player/60} Y Player: #{y_player/60}"
				if ( Gosu::distance(key[0] * 60, key[1] * 60, x_player, y_player) < 60 )
					if (especial_coletado == -1)
						especial_coletado = value
						@especiais_ativos.delete(key)
						@special_sound.play
					end
				end
			}
		end
		return especial_coletado
		# return especiais_coletados
	end
    
    # Função de explosão. Talvez seja transferida para a classe Bomba, 
    # por questão de organização, mas aqui é melhor de trabalhar com ela
    # por usar bastante o array do mapa (@tiles)
    # # Parametros
    # # x , y : player; exp : taxa de exp

	def explod ( x, y, exp,area = [], i = 1, cima_livre = true, baixo_livre = true, esq_livre = true, dir_livre = true)
	
		if (cima_livre)
			if ( ( (@tiles[x-i][y] != 0) and ( (x - i) >= 0 ) ) and (exp > 0))
				cima_livre = false if ( (@tiles[x - i][y] == 1) or (@tiles[x - i][y] == 2) )
				if (@especiais.include?([x - i,y]))
					@especiais_ativos.store([x - i,y],@especiais.delete([x - i,y]))
				end
				@tiles[x - i][y] = 4 #boom
				area << [x-i, y]
				#puts "exp [#{x - i}][#{y}] "
				exp -= 1
			else
				#puts "encerrando cima (#{i})"
				cima_livre = false
			end
			cima_livre = false if ((x - i) == 0)
		end
		if (baixo_livre)

			if (  ( (x + i) < @width ) and (exp > 0))
				if (@tiles[x + i][y] != 0)
					#puts "uhu!!"
					baixo_livre = false if ( (@tiles[x + i][y] == 1) or (@tiles[x + i][y] == 2) )
					if (@especiais.include?([x + i,y]))
						@especiais_ativos.store([x + i,y],@especiais.delete([x + i,y]))
					end
					@tiles[x + i][y] = 4 #boom
					area << [x+i, y]
					#puts "exp [#{x + i}][#{y}] "
					exp -= 1
				else
					baixo_livre = false
				end
			else
				#puts "encerrando baixo (#{i})"
				baixo_livre = false
			end
			baixo_livre = false if ((x + i) >= @width)
		end
		if (esq_livre)
			if ( ( (@tiles[x][y - i] != 0) and ( (y - i) >= 0 ) ) and (exp > 0))
				esq_livre = false if ( (@tiles[x][y - i] == 1) or (@tiles[x][y - i] == 2) )
				if ( @especiais.include?([x,y - i]))
					@especiais_ativos.store([x,y - i],@especiais.delete([x,y - i]))
				end
				@tiles[x][y - i] = 4 #boom
				area << [x, y-i]
				#puts "exp [#{x}][#{y - i}] "
				exp -= 1
			else
				#puts "encerrando esq (#{i})"
				esq_livre = false
			end
			esq_livre = false if ((y - i) == 0)
		end
		if (dir_livre)
			if ( ( (@tiles[x][y + i] != 0) and ( (y + i) < @height ) ) and (exp > 0))
				dir_livre = false if ( (@tiles[x][y + i] == 1) or (@tiles[x][y + i] == 2) )
				if ( @especiais.include?([x,y + i]) )
					@especiais_ativos.store([x,y + i],@especiais.delete([x,y + i]))
				end
				@tiles[x][y + i] = 4 #boom
				area << [x, y + i]
				#puts "exp [#{x}][#{y + i}] "
				exp -= 1
			else
				#puts "encerrando dir (#{i})"
				dir_livre = false
			end
			dir_livre = false if ((y + i) > @height)
		end
		#puts "#{cima_livre}#{baixo_livre}#{esq_livre}#{dir_livre}"
		if ( (exp > 0) and (cima_livre or baixo_livre or esq_livre or dir_livre))then
			#puts "and here we go..."
			explod( x, y, exp, area, i + 1, cima_livre, baixo_livre, esq_livre, dir_livre)
		else
			#puts "end!"
			@tiles[x][y] = 4
			area << [x,y]
			puts exp
			return area
		end
	end
end
