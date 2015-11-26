--Author Pasky13

--Mario
local mariox = 0x94
local marioy = 0x96
local mtype = 0x19
local marioside = 0x76
local mariostate = 0x7E0071

--Camera
local camx = 0x1A
local camy = 0x1C

--Object Addresses
local exbase = 0xE4
local eybase = 0xD8
local pagexbase = 0x14E0
local pageybase = 0x14D4
local otype = 0x9E
local boxpointer = 0x1662
local xoffbase = 0x01b56c
local yoffbase = 0x01b5e4
local xradbase = 0x01b5a8
local yradbase = 0x01b620

local oactive = 0x14C8

--Invulnerable objects (ghost rings etc...)
local inv_ybase = 0x1E02
local inv_xbase = 0x1E16
local inv_ypage = 0x1E2A
local inv_xpage = 0x1E3E
local itype = 0x1892

--Ghost snake

local ghosn_type = 0x17F0
local ghosn_xbase = 0x1808
local ghosn_xpage = 0x18EA
local ghosn_ybase = 0x17FC
local ghosn_ypage = 0x1814

--Ghost ship ghosts

local ghosh_type = 0x1892
local ghosh_xbase = 0x1E16
local ghosh_xpage = 0x1E3E
local ghosh_ybase = 0x1E02
local ghosh_ypage = 0x1E2A



--Projectiles
local pxbase = 0x171F
local pybase = 0x1715
local pxpage = 0x1733
local pypage = 0x1729
local projtype = 0x170B


local function mario()
	local x
	local y
	local yoffpoint = 0x1b65c
	local yradpoint = 0x1b660
	local i = 0

	memory.usememorydomain("CARTROM")

	MARIO_XIS = mainmemory.read_u16_le(mariox)
	MARIO_YPSILON = mainmemory.read_u16_le(marioy)

	x = MARIO_XIS - mainmemory.read_u16_le(camx)
	y = MARIO_YPSILON - mainmemory.read_u16_le(camy)


	if mainmemory.read_u8(mtype) == 0 or mainmemory.read_u8(0x73) ~= 0 then
		i = 1
	end
	if mainmemory.read_u8(0x0187a) ~= 0 then
		i = i + 2
	end

	local xoff = 0x02
	local xrad = 0x0C
	local yoff = memory.read_u8(yoffpoint+i)
	local yrad = memory.read_u8(yradpoint+i)
	local star = 0x01490
	local invuln = 0x1497
	gui.drawBox(x+xoff,y+yoff,x+xoff+xrad,y+yoff+yrad,0xFF0000FF,0x300000FF)
	posy = y+yoff
end

local function projectiles()
	local x
	local y
	local xoff
	local yoff
	local xrad
	local yrad
	local oend = 10
	local pid
	memory.usememorydomain("CARTROM")
	for i = 0,oend,1 do

		pid = mainmemory.read_u8(projtype + i)

		if pid ~= 0 and pid ~= 0x12 then

			x = mainmemory.read_u8(pxbase+i) + (mainmemory.read_u8(pxpage+i) * 256) - mainmemory.read_u16_le(camx)
			y = mainmemory.read_u8(pybase+i) + (mainmemory.read_u8(pypage+i) * 256) - mainmemory.read_u16_le(camy)
			xoff = memory.read_s8(0x0124e7+pid)
			yoff = memory.read_s8(0x0124f3+pid)
			xrad = memory.read_u8(0x0124ff+pid)
			yrad = memory.read_u8(0x01250b+pid)

			gui.drawBox(x+xoff,y+yoff,x+xoff+xrad,y+yoff+yrad,0xFF000000,0x500000)
		end
	end
end

local function objects()
	local oend = 20
	local x = 0
	local y = 0
	local boxid
	local xoff
	local yoff
	local xrad
	local yrad
	local fill
	local outl
	local objtype

	memory.usememorydomain("CARTROM")
	for i = 0,oend,1 do



		if mainmemory.read_u8(oactive + i) == 8 or mainmemory.read_u8(oactive + i) == 9 or mainmemory.read_u8(oactive +i) == 0xA then

			objtype = mainmemory.read_u8(otype + i)
			boxid = bit.band(mainmemory.read_u8(boxpointer+i),0x3F)
			x = mainmemory.read_u8(exbase + i) + (mainmemory.read_u8(pagexbase + i) * 256) - mainmemory.read_u16_le(camx)
			y = mainmemory.read_u8(eybase + i) + (mainmemory.read_u8(pageybase + i) * 256) - mainmemory.read_u16_le(camy)
			xoff = memory.read_s8(xoffbase + boxid)
			yoff = memory.read_s8(yoffbase + boxid)
			xrad = memory.read_u8(xradbase + boxid)
			yrad = memory.read_u8(yradbase + boxid)

			--Yoshi
			if objtype == 0x35 then
				outl = 0xFF00FF37
				fill = 0x3000FF37
			-- Power pickups
			elseif objtype >= 0x74 and objtype <= 0x81 then
				outl = 0xFF00F2FF
				fill = 0x3000F2FF
			else
				outl = 0xFFFF0000
				fill = 0x30FF0000
			end

			if objtype == 0x29 then
				xoff = -1 * 0x08
				xrad = 0x10
				yoff = 0x08
				if mainmemory.read_u8(0x1602 + i) == 0x69 then
					yoff = yoff + 0x0A
				end
			end

			--gui.text(x,y-5,string.format("%X",exbase + i))	-- Debug
			--gui.text(x,y-5,string.format("%X",objtype))	-- Debug
			--gui.text(x,y-5,xoff .. "/" .. xrad .. " " .. yoff .. "/" .. yrad) -- Debug
			--gui.text(x,y-5,string.format("%X",mainmemory.read_u8(oactive + i))) -- Debug
			if objtype ~= 0x8C then
				gui.drawBox(x+xoff,y+yoff,x+xoff+xrad,y+yoff+yrad,outl,fill)
			end
		end
	end
end

local function invulns()

	local oend = 20
	local page = 0
	local boxid
	local x
	local y
	local xoff
	local yoff
	local xrad
	local yrad
	memory.usememorydomain("CARTROM")
	--Ghost rings/Ghost house
	for i = 0,oend,1 do
			if mainmemory.read_u8(itype + i) == 0x04 or mainmemory.read_u8(itype + i) == 0x03 then
				x = mainmemory.read_u8(inv_xbase + i) + (mainmemory.read_u8(inv_xpage + i) * 256) - mainmemory.read_u16_le(camx)
				y = mainmemory.read_u8(inv_ybase + i) + (mainmemory.read_u8(inv_ypage + i) * 256) - mainmemory.read_u16_le(camy)
				xoff = 2
				xrad = 12
				yoff = 3
				yrad = 10
				gui.drawBox(x+xoff,y+yoff,x+xoff+xrad,y+yoff+yrad,0xFFFFFF00,0x30FFFF00)
			end
	end

	--Sunken ship ghosts

	for i = 0,oend,1 do
		if mainmemory.read_u8(ghosh_type +i) ~= 0 then
			x = mainmemory.read_u8(ghosh_xbase + i) + (mainmemory.read_u8(ghosh_xpage +i) * 256) - mainmemory.read_u16_le(camx)
			y = mainmemory.read_u8(ghosh_ybase + i) + (mainmemory.read_u8(ghosh_ypage +i) * 256) - mainmemory.read_u16_le(camy)
			xoff = 2
			xrad = 12
			yoff = 3
			yrad = 10
			gui.drawBox(x+xoff,y+yoff,x+xoff+xrad,y+yoff+yrad,0xFFFFFF00,0x30FFFF00)
		end
	end

	--Ghost Snake
	oend = 12
	for i = 0,oend,1 do
		if mainmemory.read_u8(ghosn_type+i) ~= 0 then
			x = mainmemory.read_u8(ghosn_xbase + i) + (mainmemory.read_u8(ghosn_xpage +i) * 256) - mainmemory.read_u16_le(camx)
			y = mainmemory.read_u8(ghosn_ybase + i) + (mainmemory.read_u8(ghosn_ypage +i) * 256) - mainmemory.read_u16_le(camy)
			xoff = 2
			xrad = 12
			yoff = 3
			yrad = 10
			gui.drawBox(x+xoff,y+yoff,x+xoff+xrad,y+yoff+yrad,0xFFFFFF00,0x30FFFF00)
		end
	end
end

--------------------------------------------------
--
-- NOSSA PARTE
--
--------------------------------------------------

-- Get tempo restante do level
local function get_level_time()

    local time_hundred = 0x7E0F31
    local time_dec = 0x7E0F32
    local time_unit = 0x7E0F33

    memory.usememorydomain("System Bus")

    local times = (100 * memory.read_u8(time_hundred) + 10 * memory.read_u8(time_dec) + memory.read_u8(time_unit))

    gui.text(0,40, times)

    return times
end

-- Calculo da fitness
--
-- (distancia*peso1 + tempoRestante*peso2 ?(+ score*peso3) + lvlCleared)
-- Objetivo: maximizar a funcao fitness
local function fitness()

    memory.usememorydomain("System Bus")

    local PLAYER_POS_ADRESS = 0x7E00D1
    local player_posX = memory.read_u16_le(PLAYER_POS_ADRESS)

    gui.text(0,60, "Mario x: " .. player_posX)

    return player_posX, get_level_time()
end

local function print_buttons()

    local controler_table = joypad.get(1)

    if (controler_table.A) then
        gui.text(450,00, "A")
    end
    if (controler_table.B) then
        gui.text(460,00, "B")
    end
    if (controler_table.X) then
        gui.text(470,00, "X")
    end
    if (controler_table.Y) then
        gui.text(480,00, "Y")
    end
    if (controler_table.Right) then
        gui.text(450,10, "R")
    end
    if (controler_table.Left) then
        gui.text(460,10, "L")
    end
    if (controler_table.Up) then
        gui.text(470,10, "U")
    end
    if (controler_table.Down) then
        gui.text(480,10, "D")
    end
end

local function get_score()

    memory.usememorydomain("WRAM")

    local low_bytes = memory.read_u16_le(SCORE_ADDRESS)
    local high_bytes = memory.readbyte(SCORE_ADDRESS+2)

    return bit.lshift(high_bytes, 16) + low_bytes
end

-- Verifica se chegou no fim da fase
local function level_end()

    memory.usememorydomain("System Bus")

    local TIMER_ADRESS = 0x7E13D6

    if (memory.read_u8(TIMER_ADRESS) == 0x49) then
        return true
    else
        return false
    end
end

--verifica se esta morrendo
function is_he_deaded_yet()
	memory.usememorydomain("System Bus")
	if (memory.read_u8(mariostate) == 0x09) then
			gui.text(0,20, "DEATH MY OLD FRIEND")
			return true
	end

	return false
end

--variaveis da is_dumb
MAX_XIS = 0 --X maximo alcancado
dumb_counter = 0 --contador de tempo pra ver se ele ta  avancando na fase
LAST_GROUND = 0
--ve se ele ta andando na fase
function is_dumb()

	if (MARIO_XIS > MAX_XIS) then	--se tiver andando ta deboas
		MAX_XIS = MARIO_XIS
		dumb_counter = 0
	else
		--se ele estiver mudando de altura ta deboas
		if (is_grounded() and (MARIO_YPSILON ~= LAST_GROUND)) then
				LAST_GROUND = MARIO_YPSILON
				dumb_counter = 0
		else

			--se nao tiver de boas roda o contador
			if (dumb_counter > 0) then
				if (emu.framecount()%60 == 0) then
					dumb_counter = dumb_counter - 1
					if (dumb_counter == 0) then
						return true
					end
				end
			else
				dumb_counter = 5 --segundos de esperteza
			end
		end
	end

	return false
end

--verifica se o mehrio ta no chao
function is_grounded()
	memory.usememorydomain("System Bus")
	local GROUNDED_ADRESS = 0x7E0072
	if (memory.read_u8(GROUNDED_ADRESS) == 0) then
		return true
	else
		return false
	end
end

--verifica se o mehrio ta no chao
function is_grounded()
	memory.usememorydomain("System Bus")
	local GROUNDED_ADRESS = 0x7E0072
	if (memory.read_u8(GROUNDED_ADRESS) == 0) then
		return true
	else
		return false
	end
end

-- Get se o title no offset (x, y) e rigido ou nao
function get_tile(offset_X, offset_Y)

    memory.usememorydomain("WRAM")

    local x = math.floor((MARIO_XIS + offset_X + 8)/16)
    local y = math.floor((MARIO_YPSILON + offset_Y)/16)

    local screenX = MARIO_XIS - memory.read_s16_le(0x1A)
    local screenY = MARIO_YPSILON - memory.read_s16_le(0x1C)
    local off = 8

    gui.drawBox(screenX+offset_X,screenY+offset_Y,screenX+offset_X+off,screenY+offset_Y+2*off,outl,fill)

    -- gui.text(0, 150,(math.floor(x/0x10)*0x1B0).."  "..(y*0x10).."  "..(x%0x10)..".."..(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10))
    return memory.readbyte(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10)
end

emu.limitframerate(false)

MutationSize = 5
mutation_chance = 20
local_mutation_size =1 -- ignora esse valor so to declarando
local_mutation_range = 10 -- o tamano da mutaçao pode ser de 1 gene até esse valor

travelDistance = 0
timeLeft = 0

max_generation =400
pop_size = 1
genoma_size = 500

seed = os.time() 
math.randomseed(seed) -- eh bom usar seed que nao fosse o tempo soh pa saber ql a seed

file = io.open("mario_seed.txt" ,"a")
io.input("mario_seed.txt")
function print_pop()
	for i=1,pop_size do
		print("candidate[",i,"].fitness=",candidate[i].fitness,"\n\tmutatio_point=",candidate[i].mutation_point)
	end
end

--funçao que retorna aleatoriamente um valor true ou false
local function random_bool()
	return (math.random(0, 1) == 1 )
end

function generate_gene()

    gene = {}

    gene.A = random_bool()
    gene.B = random_bool()
    gene.X = random_bool()
    gene.Y = random_bool()
    gene.Up = false --random_bool()
    gene.Down = random_bool()
    gene.Right = true --random_bool()
    gene.Left = false --random_bool()

    return gene
end

local function Finding_Messias( )
	candidate[2].fitness = candidate[1].fitness
	for j=1, genoma_size do
		candidate[2].genoma[j] = candidate[1].genoma[j]
	end	

	local_mutation_size = math.random(1,local_mutation_range)
	if(candidate[1].mutation_point > local_mutation_size )then
		--mutaçao local
		for j= candidate[1].mutation_point -local_mutation_size ,candidate[1].mutation_point  do	
			candidate[1].genoma[j] = {}
			candidate[1].genoma[j] = generate_gene()
		end
	else
		--se ele morrer muito no começo
		for j= 1 ,candidate[1].mutation_point do	
			candidate[1].genoma[j] = {}
			candidate[1].genoma[j] = generate_gene()
		end
	end
end

local function breed_population( )
    local offspring = {}
    local k = 1
    local mother
    local father

    --elitism
    for i = 1, pop_size do
        offspring[i] = {}
        offspring[i].genoma = {}
        for j = 1, genoma_size do
            --setando os botoes do controle
            offspring[i].genoma[j] = {}
            offspring[i].genoma[j] = candidate[i].genoma[j]
        end 
    end

    for i = 0.1*pop_size, pop_size do
        mother = math.random(1, pop_size)
        father = math.random(1, pop_size)

        -- Crossover
        for j = 1, genoma_size do
            if(random_bool())then
                candidate[i].genoma[j] = offspring[mother].genoma[j]
            else
                candidate[i].genoma[j] = offspring[father].genoma[j]
            end
        end

        if(math.random(1, 100) < mutation_chance) then
            for j = 1, genoma_size do
                if (math.random(1, 100) < MutationSize) then
                    candidate[i].genoma[j] = generate_gene()
                end
            end
        end
        candidate[i].mutation_point = -1
    end

    for i = pop_size*0.1, pop_size do
        offspring[i] = candidate[k]
        k = k + 1
    end

	print("Depois da orgia, çequissu selvagem")
	for i=1, 0.2*pop_size do
		print("candidate[",i,"].fitness=",candidate[i].fitness)
	end

    return offspring
end

local function generate_messias_chuildren()
	pop_size = 20
	--gerando os filhos do Messias
	for i=2, pop_size do
	    candidate[i] = {}
	    candidate[i].genoma = {}
	    candidate[i].fitness = 0.0
	    candidate[i].mutation_point= -1
	    for j=1, genoma_size do
	    	candidate[i].genoma[j] = {}
	    	if(math.random(1,100) > MutationSize) then
	    		candidate[i].genoma[j] = candidate[i].genoma[j]
	    	else
	    		candidate[i].genoma[j] = generate_gene()
			end
	    end
	end
end

--criar a populaçao
candidate = {}
local function create_Messias()
	for i=1, 2 do
	    candidate[i] = {}
	    candidate[i].genoma = {}
	    candidate[i].fitness = 0.0
	    candidate[i].mutation_point = -1
	    for j=1, genoma_size do
	    	candidate[i].genoma[j] = {}
	    	candidate[i].genoma[j] = generate_gene()
	    end
	end
end

print("JA ACABO, JESSICA?")
savestate.save("savedajesscica.extensaoaki") 

weight1=0.8
weight2=0.2
weight3=0.3

found_messia = false

create_Messias()

--geraçao
for	i=1, max_generation do
	--cada individuo
	for j=1, pop_size do
		local movimento = 1
		--fazer o fitness
		---quanicagesimo setimo filho sera dalse
		fim = false
		--fitnes do individuo rodando uma simulaçao
		savestate.load("savedajesscica.extensaoaki")
		while not fim do
			mario()
			objects()
			invulns()
			projectiles()
			get_level_time()
	    	print_buttons()
			get_tile(32, 32)
			fitness()

			joypad.set(candidate[j].genoma[movimento], 1)

			if (emu.framecount()%20 == 0) then
				movimento = movimento + 1
			end

			--- if fim de simulaçao
			if (is_dumb() or is_he_deaded_yet() or level_end()) then
				fim = true
				travelDistance, timeLeft = unpack{fitness()}
				candidate[j].fitness = weight1 * travelDistance + weight2 * timeLeft-- + weight3 * get_score()
				MAX_XIS = 0 --X maximo alcancado
				dumb_counter = 0 --contador de tempo pra ver se ele ta  avancando na fase
				LAST_GROUND = 0
				if(level_end())then
					candidate[j].fitness = candidate[j].fitness + 1000---bonus por termianr o level
					--cria a populaçao em baze o gene do messia uma unica vez
					if(not found_messia) then
						generate_messias_chuildren()
					end
					found_messia = true
				else 
					candidate[j].mutation_point = movimento
				end
			end
	   		emu.frameadvance()
		end		
	end
	--selecionar a populaçao
	table.sort(candidate, function ( a,b )
		return (a.fitness > b.fitness)
	end)
	print("========GENARATION", i, "==================")
	print_pop()
	if(not found_messia) then 
		Finding_Messias()
	else  
		breed_population()
	end
	--reproduzir a populaçao
end
------ dalse.... kd vc???
io.write("seed:",seed,"best fitness:",candidate[0].fitness)

io.close("mario_seed.txt")
