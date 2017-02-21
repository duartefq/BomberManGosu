class Player 
	attr_reader :x, :y
	attr_accessor :morreu, :vel, :gameover, :concluido_nivel
	
	def initialize (window, map)

		@window = window
		@map = map # O mapa
		@x = 0
		@y = 0

		# Tiles do Player, cada instância é uma pose diferente.
		@standing_front, @walk1_front, @walk2_front,
		@standing_behind, @walk1_behind, @walk2_behind, 
		@standing_side_right, @walk1_side_right, @walk2_side_right,
		@walk1_side_left, @walk2_side_left, @standing_side_left =
				* Gosu::Image.load_tiles(window, "img/player/player.png", 38, 59, false)

		@morrendo = Gosu::Image.load_tiles(@window, "img/player/sprite_morrendo.png", 60, 60, true)
		@pose_exito = Gosu::Image.new(@window, "img/player/fase_concluida.png", true)
		@sprite_morrendo = 0

		@dir = :down # Direção inicial
		@cur_image = @standing_behind # Pose inicial
		@morreu = false
		@concluido_nivel = false
		@walking = false
		@vel = 3 # Velocidade, evite usar 4, 8, 12, etc rs.

		@player_out_sound = Gosu::Sample.new(@window, "music/system/player_out.wav")
		#@tocou_out_sound = false

		@time = 500
		@gameover = false

	end

	def update

		#puts "x: #{@x} y: #{@y}"
		if @concluido_nivel
			@cur_image = @pose_exito
		else	
			if @morreu
				if (@sprite_morrendo.zero?)
					@player_out_sound.play 
				end
				if ( Gosu::milliseconds > @time )
					if (@sprite_morrendo < 6)
						@cur_image = @morrendo[@sprite_morrendo]
						@sprite_morrendo += 1
						@time = Gosu::milliseconds + 250
					else
						@gameover = true
					end
				end
			else
				if ( not @walking )
					if (@dir == :down) then 
						@cur_image = @standing_front
					elsif (@dir == :up) 
						@cur_image = @standing_behind
					elsif (@dir == :right) 
						@cur_image = @standing_side_right
					elsif (@dir == :left) 
						@cur_image = @standing_side_left
					end
				else
					if ( (@dir == :down) and @map.move_possivel( @x, @y, 1, 1 ))
						@y += @vel
						if ( (@y % 60) != 0)
							@y += @vel
							if (Gosu::milliseconds / (875/(@vel + 1)) % 2 == 0) then
								@cur_image = @walk1_front
							else
								@cur_image = @walk2_front
							end

							if ( (@y % 60) == 0)
								@walking = false
							end
						end
					elsif (@dir == :up and (@map.move_possivel( @x, @y, 1, -1 )) )
						#if ( (@y - 1) > 0)
							@y -= @vel
							if ( (@y % 60) != 0)
								@y -= @vel
								if (Gosu::milliseconds / (875/(@vel + 1)) % 2 == 0) then
									@cur_image = @walk1_behind
								else
									@cur_image = @walk1_behind
								end
								if ( (@y % 60) == 0)
									@walking = false
								end
							end
						#end

					elsif (@dir == :right and @map.move_possivel( @x, @y, 0, 1 ))
						@x += @vel
						if ( (@x % 60) != 0) then
							@x += @vel
							if (Gosu::milliseconds / (875/(@vel + 1)) % 2 == 0) then
								@cur_image = @walk1_side_right
							else
								@cur_image = @walk2_side_right
							end
							if ( (@x % 60) == 0)
								@walking = false 
							end
						end

					elsif (@dir == :left and (@map.move_possivel( @x, @y, 0, -1 )) )
						#if ( (@x - 1) > 0)
							@x -= @vel
							if ( (@x % 60) != 0) then
								@x -= @vel
								if (Gosu::milliseconds / (875/(@vel + 1) ) % 2 == 0) then
									@cur_image = @walk1_side_left
								else
									@cur_image = @walk2_side_left
								end
								if ( (@x % 60) == 0)
									@walking = false
								end
							end
						#end

					end
				end

				especial_coletado = @map.pegou_especial?(@x, @y)
				if ( especial_coletado != -1 )
					@window.especiais_ativos[especial_coletado] = true 
					# puts "UHUL!! Peguei o especial #{especial_coletado}"
				end
			end
		end
	end

	def print_array ( map )
		for i in 0...map.size do 
			for j in 0...map[i].size do 
				print "#{map[i][j]} "
			end
		end
	end

	def button_down ( id )
		if ( ( id == Gosu::Button::KbDown ) and not @walking)
			@walking = true
			@dir = :down
		elsif ( ( id == Gosu::Button::KbUp ) and not @walking)
			@walking = true
			@dir = :up
		elsif ( ( id == Gosu::Button::KbLeft ) and not @walking)
			@walking = true
			@dir = :left 
		elsif ( ( id == Gosu::Button::KbRight ) and not @walking)
			@walking = true
			@dir = :right 
		else
			@walking = false
		end
	end

	def button_up ( id )
		if ( id == Gosu::Button::KbDown )
			@walking = false
		elsif ( id == Gosu::Button::KbUp )
			@walking = false
		elsif ( id == Gosu::Button::KbLeft )
			@walking = false
		elsif ( id == Gosu::Button::KbRight )
			@walking = false
		end
	end

	def draw
		@cur_image.draw(@x, @y, 3)
	end
end
