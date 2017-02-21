# Traça rota de perseguição, baseado nas coordenadas do player, a cada @time (definido)
# Caso haja algum impedimento no caminho, o inimigo entra em movimento aleatório (cima-baixo ou direita-esquerda)
# Se alcançar o jogador, jogador morre.
# Se for atingido por bomba, inimigo morre.

class Enemy
	attr_accessor :vel

	def initialize (window, map, player)
		@window = window
		@map = map
		inicializa_posicao

		@char = Gosu::Image.load_tiles(@window, "img/player/sprite_enemy.png", 60, 60, true)
		@sprite_atual = 0


		@player = player

		@time = 5000
		@mov = []
		@dir = nil

		@morto = false
		@time_sprite_enemy = 0
		@finalizado = false

		getMovimento(@player.x, @player.y)
	end

	def inicializa_posicao
		# Pega pos x , y de map where map[x][y] == 3 (livre)
		pos_livres = getPosicoesLivres
		pos = pos_livres[rand(pos_livres.size)] # Pega posição random
		@x = pos[0]
		@y = pos[1]
	end

	# Gera um array de posições possíveis com no mínimo três blocos de espaço
	def getPosicoesLivres
		pos_livres = []
		size = @map.tiles.size
		for i in 0...size
			for j in 1...@map.tiles[i].size
				if ( (@map.tiles[ ((i - 1)<0)?0:(i - 1) ][j] == 3) and (@map.tiles[i][j] == 3) and (@map.tiles[((i + 1)>(size - 1))?0:(i + 1)][j] == 3) )
					pos_livres << [i * 60,j* 60]
				end
			end
		end
		return pos_livres
	end

	def update
		#puts "Mov: #{@mov}"
		
		if ( not @morto )
			if ( (Gosu::milliseconds % 15).zero? )
				@sprite_atual = (@sprite_atual < 2)?(@sprite_atual + 1):0
			end

			if ( (Gosu::milliseconds > @time) or (@mov == []) )
				getMovimento(@player.x, @player.y)
				@time += 1000
			end

			if ( @dir.nil? )
				getDirecao
				#puts "Pegando direcao"
			else
				if ( ( @dir == :right ) )
					if @map.move_possivel(@x,@y,0,1)
						@x += 1
						if ( not ( @x % 60 ).zero? )
							@x += 1
							if ( @x % 60 ).zero?
								@dir = nil
								@mov[0] -= 1
							end
						end
					else
						@dir = movimento_aleatorio(0,1)
					end
				elsif ( ( @dir == :left )  )
					if @map.move_possivel(@x,@y,0,-1)
						@x -= 1
						if ( not (@x % 60 ).zero? )
							@x -= 1
							if (@x % 60 ).zero?
								@dir = nil
								@mov[0] += 1
							end
						end
					else
						@dir = movimento_aleatorio(0,-1)
					end
				elsif ( ( @dir == :up ) )
					if @map.move_possivel(@x,@y,1,-1)
						@y -= 1
						if ( not ( @y % 60 ).zero? )
							@y -= 1
							if ( @y % 60 ).zero?
								@dir = nil
								@mov[1] += 1
							end
						end
					else
						@dir = movimento_aleatorio(1,-1)
					end
				elsif ( ( @dir == :down ) )
					if @map.move_possivel(@x,@y,1,1)
						@y += 1
						if ( not ( @y % 60 ).zero? )
							@y += 1
							if ( @y % 60 ).zero?
								@dir = nil
								@mov[1] -= 1
							end
						end
					else
						@dir = movimento_aleatorio(1,1)
					end
				end
			end
			player_morreu?(@player.x, @player.y)
		else
			if (not @finalizado)
				if ( Gosu::milliseconds > @time_sprite_enemy )
					if (@sprite_atual < 7)
						@sprite_atual += 1
						@time_sprite_enemy = Gosu::milliseconds + 250
					else
						@finalizado = true
					end
				end
			end
		end

		enemy_morrey?
	end

	def movimento_aleatorio ( dir, tentativa )
		retorno = nil
		if ( @map.move_possivel(@x, @y, dir, (tentativa * -1)) )
			retorno = (dir.zero?)?(((tentativa*-1)<0)?(:left):(:right)):(((tentativa*-1)<0)?(:up):(:down))
			#puts "Vou para a posicao #{dir} - #{tentativa * -1}"
		elsif ( @map.move_possivel(@x, @y, (dir.zero?)?1:0, (tentativa * -1)) )
			dir_aux = (dir.zero?)?1:0
			retorno = (dir_aux.zero?)?(((tentativa*-1)<0)?(:left):(:right)):(((tentativa*-1)<0)?(:up):(:down))
			#puts "Vou para a posicao #{dir_aux} - #{tentativa * -1}"
		end
		return retorno
	end

	def player_morreu?(x_player, y_player)
		if ( Gosu::distance(@x, @y, x_player, y_player) < 59 )
			@player.morreu = true
		end
	end

	def enemy_morrey?
		@morto = true if ( @map.tiles[@x/60][@y/60] == 4 )
	end

	def getMovimento (x_player, y_player)
		# puts "Posicao player_x: #{x_player}\nPosicao player_y: #{y_player}"
		# puts "Posicao inimigo_x: #{@x}\nPosicao inimigo_y: #{@y}"
		@mov = [ ( (x_player/60) - (@x/60)), ((y_player/60) - (@y/60)) ]
	end

	def getDirecao
		if ( ( @mov[0] != 0 ) or ( @mov[1] != 0 ) )
			if ( @mov[0] != 0)
				if @map.move_possivel(@x,@y,0,(@mov[0] < 0)?-1:1) 
					@dir = (@mov[0]<0)?(:left):(:right)
				else
					@dir = movimento_aleatorio(0,@mov[0])
				end
			else
				if @map.move_possivel(@x,@y,1,(@mov[1] < 0)?-1:1) 
					@dir = (@mov[1]<0)?(:up):(:down)
				else
					@dir = movimento_aleatorio(1,@mov[1])
				end
			end
		end
	end

	def draw
		@char[@sprite_atual].draw(@x, @y, 3) if not @finalizado
	end

end
