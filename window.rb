class Window < Gosu::Window
	attr_accessor :bombas_possiveis, :especiais_ativos

	def initialize
		super(960, 660, false) # 16x11
		self.caption = "BomberMan"
		@background = Gosu::Image.new(self, "img/menu/menu_background.png", true)
		@pause_image = Gosu::Image.new(self, "img/player/pause.png", true)

		@playing = false
		@running = false

		@select = Gosu::Sample.new(self, "music/menu/select.wav")
		@confirm = Gosu::Sample.new(self, "music/menu/confirm.wav")
		
		@pause = Gosu::Sample.new(self, "music/system/pause.wav")
		menu
	end

	def menu
        
        @running = false
        @menu = true

        @menu_option_normal = [Gosu::Image.new(self, "img/menu/opcao_novojogo.png", true), Gosu::Image.new(self, "img/menu/opcao_continuar.png", true), Gosu::Image.new(self, "img/menu/opcao_sair.png", true)]
        @menu_option_selecionado = [Gosu::Image.new(self, "img/menu/opcao_novojogo_selecionado.png", true), Gosu::Image.new(self, "img/menu/opcao_continuar_selecionado.png", true), Gosu::Image.new(self, "img/menu/opcao_sair_selecionado.png", true)]
        @menu_atual = [@menu_option_selecionado[0], @menu_option_normal[1], @menu_option_normal[2]]
        @menu_option = 0

        @menu_bar = Gosu::Image.new(self, "img/menu/menu_bar.png", true)
        @count_menu_bar = 0
        @menu_bar_concluido = false
        @x_menu_bar = 960
        @y_menu_bar = 180

        draw_menu
    end

    def initialize_game(nivel)
		@terreno = Gosu::Image.new(self, "img/stage/bomber.bmp", true)
		arquivo_fase = "img/stage/fase" + ((nivel > 1)?1:nivel).to_s + ".jpg"
		@fase = Gosu::Image.new(self, arquivo_fase, true)

		# Legenda: 0 = + Velocidade; 1 = + Bombas Simultaneas; 2 = + Alcance Bomba
		@especiais_ativos = [false, false, false]
		# Especiais da Fase
		@especiais = [0, 1, 2]
		# Duração do especial, em segundos.
		@duracao_especial = 10
		@tempo_especiais = [0,0,0]
		# for i in 0...(5 - nivel)
		# 	@especiais << rand(2)
		# 	@especiais_ativos << false
		# 	@tempo_especiais << 0
		# end

		# Duração do especial, em segundos.
		@duracao_especial = 10

		mapa = "stages/map" + ((nivel > 3)?3:nivel).to_s + ".txt"
		@map = Map.new(self, mapa, @especiais)
		@player = Player.new(self, @map)

		@enemy = []
		numero_inimigos = (nivel > 3)?3:(nivel + 1)
		for i in 0...numero_inimigos do 
			@enemy << Enemy.new(self, @map, @player)
		end
		# @enemy = Enemy.new(self, @map, @player)
		# @enemy2 = Enemy.new(self, @map, @player)

		@bombs = []
		@numero_bombas = 0
		@bombas_possiveis = 2


		@nivel = nivel
		@taxa_expansao = 4

		@concluido_nivel = false
	end

	def update
		if not @menu
			update_game if @running
		else
			if ( (@x_menu_bar > 620) )
				if (Gosu::milliseconds > @count_menu_bar)
					@x_menu_bar -= 4
					@count_menu_bar = Gosu::milliseconds + 5
				end
			else
				@menu_bar_concluido = true
			end
		end
	end

	def update_game
		@player.update
	    
	    for enemy in @enemy
	    	enemy.update
		end

		if (@player.gameover)
			@playing = false
			@running = false
			menu
		end

	    @map.update

	    # + Velocidade
	    if ( @especiais_ativos[0] )
	    	@vel *= 2
	    	@especiais_ativos[0] = false
	    	@tempo_especiais[0] = (Gosu::milliseconds / 1000) + @duracao_especial
	    end

	    # + Bombas Simultaneas
	    if ( @especiais_ativos[1] )
	    	@bombas_possiveis += ((2 * @nivel) > 6)?6:(2 * @nivel)
	    	@especiais_ativos[1] = false
	    	@tempo_especiais[1] = (Gosu::milliseconds / 1000) + @duracao_especial
	    end

	    # + Alcance Bomba
	    if ( @especiais_ativos[2] )
	    	# @taxa_expansao *= (@nivel > 4)?4:@nivel
	    	puts "Aumentando taxa!"
	    	@taxa_expansao *= (@nivel > 4)?4:(@nivel + 1)
	    	@especiais_ativos[2] = false
	    	@tempo_especiais[2] = (Gosu::milliseconds / 1000) + @duracao_especial
	    end

	    if (not @tempo_especiais.select{|v| v > 0}.empty?)
	    	for i in 0...@tempo_especiais.size
	    		if ( ((Gosu::milliseconds/1000) > @tempo_especiais[i]) and !@tempo_especiais[i].zero? )
	    			desativar_especial(i)
	    			puts "OI!"
	    		end
	    	end
	    end

	    if (not @bombs.empty?)
		    for i in 0...@numero_bombas
		    	if (not @bombs[i].nil?)
					@bombs[i].update
				end
		    end
		end

	    if ( @numero_bombas > 0 ) then 
			for i in (0...@numero_bombas)
				if (not @bombs[i].nil?)
					if (not @bombs[i].actived) then 
						@bombs[i] = nil
						@bombs.compact!
						@numero_bombas -= 1
					end 
				end
			end
	    end

	    @map.pegou_coin?(@player.x, @player.y)
	    
	    @concluido_nivel = @map.pegou_tudo?

	    if (@concluido_nivel) then
	    	@time = (Gosu::milliseconds + 500) if not @player.concluido_nivel
	    	@player.concluido_nivel = true

	    	initialize_game(@nivel += 1) if (Gosu::milliseconds > @time)
	    end
	end

	def desativar_especial ( index )
		if (index == 0)
			@vel /= 2
			@tempo_especiais[0] = 0
		elsif (index == 1)
			@bombas_possiveis -= ((2 * @nivel) > 6)?6:(2 * @nivel)
			@tempo_especiais[1] = 0
		else
			@taxa_expansao /= (@nivel > 4)?4:(@nivel + 1)
			@tempo_especiais[2] = 0
		end
	end

	def draw
		if @menu
			draw_menu
		else
			draw_game
		end
	end

	def draw_menu
        @background.draw(0,0,0)
        if (@menu_bar_concluido)
	        x = 640
	        y = 200
	        for option in @menu_atual do
	        	option.draw(x,y,1)
	        	y += 80
	        end
	    end
	    @menu_bar.draw(@x_menu_bar, @y_menu_bar, 1)
    end

	def draw_game
		@player.draw
		#@terreno.draw(0, 0, 2)
		@fase.draw(0, 0, 1)
		@map.draw
		if (not @bombs.empty?)
			for i in 0...@numero_bombas
				if (not @bombs[i].nil?)
					@bombs[i].draw
				end
			end
		end

		if not @running
			@pause_image.draw(200,140,4)
		end

		for enemy in @enemy
			enemy.draw
		end
	end

	def button_down(id)
		if (not @menu)
			button_down_game(id)
		else
			button_down_menu(id)
		end
	end

	def button_down_menu(id)
		 if (id == Gosu::Button::KbDown) then
            @menu_atual[@menu_option] = @menu_option_normal[@menu_option]
            @menu_option += 1
            @menu_option = 2 if (@menu_option > 2)
            @menu_atual[@menu_option] = @menu_option_selecionado[@menu_option]
            @select.play
        end
        if (id == Gosu::Button::KbUp) then
            @menu_atual[@menu_option] = @menu_option_normal[@menu_option]
            @menu_option -= 1
            @menu_option = 0 if (@menu_option < 0)
            @menu_atual[@menu_option] = @menu_option_selecionado[@menu_option]
            @select.play
        end
        if ( (id == Gosu::Button::KbSpace) and @menu_bar_concluido )then
        	@confirm.play
            if (@menu_option == 0)
                initialize_game(0)
                @playing = true
                @running = true
                @menu = false
            elsif (@menu_option == 1)
                @menu = false if @playing
                @running = true
            else (@menu_option == 2)
                close
            end
        end
	end

	def button_down_game(id)
		close if (id == Gosu::Button::KbEscape)

		if @running
			if ( id == Gosu::Button::KbSpace and not @player.morreu and (@bombs.size < @bombas_possiveis) and (@player.x % 60).zero? and (@player.y % 60).zero?)
				@bombs << Bomba.new(self, 3, @map, @taxa_expansao, @player)
				@numero_bombas += 1
			end

			@player.button_down(id) 
		end

		if ( id == Gosu::Button::KbM )
			@running = false
			@confirm.play
			menu
		end

		if ( id ==  Gosu::Button::KbP)
			@pause.play
			@running = !@running 
		end

	end
end
