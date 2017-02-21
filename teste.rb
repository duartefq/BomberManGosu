# Imprime array
def print_array ( map )
	for i in 0...map.size do 
		for j in 0...map[i].size do 
			print "#{map[i][j]} "
		end
		puts
	end
end

# Função de Explosão (recursiva)
# c_end = false, b_end = false, e_end = false, d_end = false
def explod ( map, x, y, exp, player_x, player_y, area = [], i = 1, cima_livre = true, baixo_livre = true, esq_livre = true, dir_livre = true) # x , y : player; i : expansao; exp : taxa de exp
	
	if (cima_livre)
		if ( ( (map [x - i][y] != '#') and ( (x - i) >= 0 ) ) and (exp > 0))
			map[x - i][y] = 'x' #boom
			area << [x-i, y]
			puts "exp [#{x - i}][#{y}] "
			exp -= 1
		else
			puts "encerrando cima (#{i})"
			cima_livre = false
		end
		cima_livre = false if ((x - i) == 0)
	end
	if (baixo_livre)
		if ( ( (map [x + i][y] != '#') and ( (x + i) < map.size ) ) and (exp > 0))
			map[x + i][y] = 'x' #boom
			area << [x+i, y]
			puts "exp [#{x + i}][#{y}] "
			exp -= 1
		else
			puts "encerrando baixo (#{i})"
			baixo_livre = false
		end
		baixo_livre = false if ((x + i) == map.size - 1)
	end
	if (esq_livre)
		if ( ( (map [x][y - i] != '#') and ( (y - i) >= 0 ) ) and (exp > 0))
			map[x][y - i] = 'x' #boom
			area << [x, y-i]
			puts "exp [#{x}][#{y - i}] "
			exp -= 1
		else
			puts "encerrando esq (#{i})"
			esq_livre = false
		end
		esq_livre = false if ((y - i) == 0)
	end
	if (dir_livre)
		if ( ( (map [x][y + i] != '#') and ( (y + i) < map[x].size ) ) and (exp > 0))
			map[x][y + i] = 'x' #boom
			area << [x, y + i]
			puts "exp [#{x}][#{y + i}] "
			exp -= 1
		else
			puts "encerrando dir (#{i})"
			dir_livre = false
		end
		dir_livre = false if ((y + i) == map[x].size - 1)
	end
	puts "#{cima_livre}#{baixo_livre}#{esq_livre}#{dir_livre}"
	if ( (exp > 0) and (cima_livre or baixo_livre or esq_livre or dir_livre))then
		puts "and here we go..."
		explod( map, x, y, exp, player_x, player_y, area, i + 1, cima_livre, baixo_livre, esq_livre, dir_livre)
	else
		puts "end!"
		map[x][y] = 'x'
		area << [x,y]
		puts exp
		return area
	end
end

map = [ ['-','-','-','-','-','-'],
		['-','-','-','o','-','-'],
		['-','-','-','o','-','-'],
		['-','-','#','-','o','o'],
		['-','-','-','-','-','-'],
		['-','-','-','#','-','-'],
		['-','-','-','-','-','-'],
		['-','-','-','-','-','-'] ]

# Arguments
# map : mapa; x , y : bomb; i : expansao; exp : taxa de exp; player_x, player_y : pos do player
print_array map


explod(map,3,3,9,6,3)



print_array map
puts
puts "oi: #{map.size}"
puts "io: #{map[0].size}"
