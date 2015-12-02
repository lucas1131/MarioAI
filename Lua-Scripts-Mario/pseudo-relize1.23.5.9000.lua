-- SPRITES KEYS
YOSHI = 0x35
YOSHI_EGG = 0x2C
BABY_YOSHI = 0x2D
WIGGLER = 0x86
KOOPA_SHELLS_START = 0xDA
KOOPA_SHELLS_END = 0xDD
CHUCK_START = 0x91
CHUCK_END = 0x9B
KEYHOLE = 0x0E
UNUSED = 0x12
UNUSED2 = 0x36
LVL_MSG = 0x19
COIN = 0x21
P_SWITCH = 0x3E
SPRINGBOARD = 0x2F
THROW_BLOCK = 0x53
TITLES_START = 0x54
TITLES_END = 0x6D
USELESS_START = 0x45
USELESS_END = 0x4c
PICKUP_START = 0x74
PICKUP_END = 0x8F
USELESS_2_START = 0x9C
USELESS_2_END = 0xFF
-- IF NEEDED CONTINUE STARTING AT 0x90
-- http://www.smwiki.net/wiki/Sprite

-- GLOBAL ADDRESSES
MARIO_X_ADDRESS = 0x94
MARIO_Y_ADDRESS = 0x96
MARIO_FACING_ADDRESS = 0x76
PLAYER_STATE_ADDRESS = 0x7E0071
PLAYER_POS_ADDRESS = 0x7E00D1
TIMER_ADDRESS = 0x7E13D6
SCORE_ADDRESS = 0x0F34
GROUNDED_ADDRESS = 0x7E0072
ENEMY_X_BASE_ADDRESS = 0xE4
ENEMY_y_BASE_ADDRESS = 0xD8
PAGE_X_BASE_ADDRESS = 0x14E0
PAGE_Y_BASE_ADDRESS = 0x14D4
OBJECT_TYPE_ADDRESS = 0x9E
CAM_X_ADDRESS = 0x1A
CAM_Y_ADDRESS = 0x1C

function get_mario_pos()

	memory.usememorydomain("CARTROM")
	MARIO_XIS = mainmemory.read_u16_le(MARIO_X_ADDRESS)
	MARIO_YPSILON = mainmemory.read_u16_le(MARIO_Y_ADDRESS)
end

function get_level_time()

    local time_hundred = 0x7E0F31
    local time_dec = 0x7E0F32
    local time_unit = 0x7E0F33

    memory.usememorydomain("System Bus")

    local times = (100 * memory.read_u8(time_hundred) + 10 * memory.read_u8(time_dec) + memory.read_u8(time_unit))

    return times
end

function get_score()

	memory.usememorydomain("System Bus")

	return memory.read_u24_le(SCORE_ADDRESS)
end

-- Fitness function
--
-- maxDistance*weight1 + timeLeft*weight2 + score*weight3 + clearBonus
-- need to MAXIMIZE fitness
function fitness()

    memory.usememorydomain("System Bus")

    local player_posX = memory.read_u16_le(PLAYER_POS_ADDRESS)

    return player_posX*weight1 + get_level_time()*weight2 + get_score()*weight3
end

-- Verifica se chegou no fim da fase
function level_end()

    memory.usememorydomain("System Bus")

    if memory.read_u8(TIMER_ADDRESS) == 0x49 then
        clearBonus = 1000
        return true
    else
    	clearBonus = 0
        return false
    end
end

--verifica se esta morrendo
function is_he_deaded_yet()

	memory.usememorydomain("System Bus")

	if (memory.read_u8(PLAYER_STATE_ADDRESS) == 0x09) then
			-- gui.text(0,20, "DEATH MY OLD FRIEND")
			return true
	end

	return false
end

-- Check if mario is advancing
function is_dumb()

	if MARIO_XIS > MAX_XIS then	--se tiver andando ta deboas
		MAX_XIS = MARIO_XIS
		dumb_counter = 0
	else
		--se ele estiver mudando de altura ta deboas
		if is_grounded() and (MARIO_YPSILON ~= LAST_GROUND) then
				LAST_GROUND = MARIO_YPSILON
				dumb_counter = 0
		else

			--se nao tiver de boas roda o contador
			if dumb_counter > 0 then
				if emu.framecount()%60 == 0 then
					dumb_counter = dumb_counter - 1
					if dumb_counter == 0 then
						return true
					end
				end
			else
				dumb_counter = 4 -- segundos de esperteza
			end
		end
	end

	return false
end

--verifica se o mehrio ta no chao
function is_grounded()

	memory.usememorydomain("System Bus")

	if (memory.read_u8(GROUNDED_ADDRESS) == 0) then
		return true
	else
		return false
	end
end

function is_hostile(key)

	-- -- Other things
	-- if key == YOSHI then
	-- 	return false
	-- end
	-- if key == YOSHI_EGG then
	-- 	return false
	-- end
	-- if key == BABY_YOSHI then
	-- 	return false
	-- end
	-- if key == COIN then
	-- 	return false
	-- end

	-- Enemies
	-- MOST of the sprites at 0x48 and below are enemies. Not all but most.
	if key <= 0x48 then
		return true
	end
	if key == WIGGLER then
		return true
	end
	if key >= KOOPA_SHELLS_START and key <= KOOPA_SHELLS_END then
		return true
	end
	-- These are some other enemies like moles
	if key >= 0x4D and key <= 0x52 then
		return true
	end
	-- Chuck enemies
	if key >= CHUCK_START and key <= CHUCK_END then
		return true
	end

	-- if key == KEYHOLE then
	-- 	return false
	-- end
	-- if key == UNUSED then
	-- 	return false
	-- end
	-- if key == UNUSED2 then
	-- 	return false
	-- end
	-- if key == LVL_MSG then
	-- 	return false
	-- end
	-- if key == P_SWITCH then
	-- 	return false
	-- end
	-- if key == SPRINGBOARD then
	-- 	return false
	-- end
	-- if key == THROW_BLOCK then
	-- 	return false
	-- end
	-- if key >= TITLES_START and key <= TITLES_END then
	-- 	return false
	-- end
	-- if key >= USELESS_START and key <= USELESS_END then
	-- 	return false
	-- end
	-- if key >= PICKUP_START and key <= PICKUP_END then
	-- 	return false
	-- end
	-- if key >= USELESS_2_START and key <= USELESS_2_END then
	-- 	return false
	-- end

	return false
end

-- Get se o title no offset (x, y) e rigido ou nao
function get_tile(offset_X, offset_Y)

    memory.usememorydomain("WRAM")

    local x = math.floor((MARIO_XIS + offset_X + 8)/16)
    local y = math.floor((MARIO_YPSILON + offset_Y)/16)

    local screenX = MARIO_XIS - memory.read_s16_le(0x1A)
    local screenY = MARIO_YPSILON - memory.read_s16_le(0x1C)
    local off = 8

    -- gui.drawBox(screenX+offset_X, screenY+offset_Y, screenX+offset_X+off, screenY+offset_Y-off, 0xFFFFFFFF, 0x45FFFFFF)

    -- gui.text(0, 150,(math.floor(x/0x10)*0x1B0).."  "..(y*0x10).."  "..(x%0x10)..".."..(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10))
    return memory.readbyte(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10)
end

function get_enemy(target_x, target_y)

	memory.usememorydomain("WRAM")

	local screenX = MARIO_XIS - memory.read_s16_le(0x1A)
	local screenY = MARIO_YPSILON - memory.read_s16_le(0x1C)

	memory.usememorydomain("CARTROM")

	local enemyX
	local enemyY
	local objKey

	local offset = 16
	local yoffset1 = 12
	local yoffset2 = 16
	local oend = 20 -- ????
    local off = 8

    -- gui.drawBox(screenX+target_x, screenY+target_y, screenX+target_x+off, screenY+target_y-off, 0xFFFFA0A0, 0x45FFA0A0)

	for i = 0, oend do

		objKey = mainmemory.read_u8(OBJECT_TYPE_ADDRESS + i)

		if is_hostile(objKey) then

			enemyX = mainmemory.read_u8(ENEMY_X_BASE_ADDRESS + i) +
					(mainmemory.read_u8(PAGE_X_BASE_ADDRESS + i) * 256) -
					 mainmemory.read_u16_le(CAM_X_ADDRESS)

			enemyY = mainmemory.read_u8(ENEMY_y_BASE_ADDRESS + i) +
					(mainmemory.read_u8(PAGE_Y_BASE_ADDRESS + i) * 256) -
					 mainmemory.read_u16_le(CAM_Y_ADDRESS)

			-- gui.drawBox(enemyX, enemyY-yoffset1, enemyX+offset, enemyY+yoffset2, 0xFF6e002d, 0x106e002d)
			-- 0000 0000 - Alpha channel (bit 24)
			-- 0000 0000 - Red channel (bit 16)
			-- 0000 0000 - Green channel (bit 8)
			-- 0000 0000 - Blue channel (bit 0)

			if (screenX+target_x >= enemyX) and (screenX+target_x <= enemyX+offset) and
			   (screenY+target_y >= enemyY-yoffset1) and (screenY+target_y <= enemyY+yoffset2) then
			   	return 1
			end
		end
	end
	return 0
end

function should_move()
	
	-- -- Rigid blocks getters
	-- gui.text(10, 80,  get_tile(32, -8	))
	-- gui.text(10, 100, get_tile(32, 16	))
	-- gui.text(10, 120, get_tile(32, 40	))
	-- gui.text(30, 80,  get_tile(64, -8	))
	-- gui.text(30, 100, get_tile(64, 16	))
	-- gui.text(30, 120, get_tile(64, 40	))
	-- gui.text(50, 80,  get_tile(96, -8	))
	-- gui.text(50, 100, get_tile(96, 16	))
	-- gui.text(50, 120, get_tile(96, 40	))

	-- -- Enemies getters
	-- gui.text(10, 150, get_enemy(32, 0	))
	-- gui.text(10, 170, get_enemy(32, 24	))
	-- gui.text(10, 190, get_enemy(32, 48	))
	-- gui.text(30, 150, get_enemy(64, 0	))
	-- gui.text(30, 170, get_enemy(64, 24	))
	-- gui.text(30, 190, get_enemy(64, 48	))
	-- gui.text(50, 150, get_enemy(96, 0	))
	-- gui.text(50, 170, get_enemy(96, 24	))
	-- gui.text(50, 190, get_enemy(96, 48	))

	-- Wtf esses ifs?

	if  (get_tile(32, -8) == 1) or (get_tile(32, 16) == 1) or (get_tile(32, 40) == 0) or
	(get_tile(64, -8) == 1) or (get_tile(64, 16) == 1) or (get_tile(64, 40) == 0) or
	(get_tile(96, -8) == 1) or (get_tile(96, 16) == 1) or (get_tile(96, 40) == 0) then
		return true
	end

	if  (get_enemy(32, 0) == 1) or (get_enemy(32, 24) == 1) or (get_enemy(32, 48) == 1) or
	(get_enemy(64, 0) == 1) or (get_enemy(64, 24) == 1) or (get_enemy(64, 48) == 1) or
	(get_enemy(96, 0) == 1) or (get_enemy(96, 24) == 1) or (get_enemy(96, 48) == 1) then
		return true
	end

	return false
end

--funaçoq ue retorn aleatoriamente um valor true ou false
function random_bool()

	return (math.random(1, 10) > 5)
end

function generate_gene()

	gene = {}

	gene.A = random_bool()
	gene.B = random_bool()
	gene.X = random_bool()
	gene.Y = random_bool()
	gene.Up = random_bool()
	gene.Down = random_bool()
	gene.Right = random_bool()
	gene.Left = random_bool()

	return gene
end

function print_pop()
	for i = 1, pop_size do
		print("candidate[",i,"].fitness=",candidate[i].fitness)
	end
end

-- criar a populaçao inicial que é composta por 2 individuos 
-- um que sera o individuo que ficara sendo testado e outra que sera 
-- guardado o melhor individuo produzido até entao

local function create_Messiah()
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

-- Funçao que ira achar o individuo modelo, onde o individuo 
-- de melhor fitness sempre sera guardado e o novo individuo é uma 
-- mutaçao do melhor individuo,
local function Finding_Messiah( )

	--guardando o primeiro individuo no segundo, pois o primeiro é melhor
	candidate[2] = candidate[10]	
	--fazendo a "mutaçao local" que seria a mutaçao no nos genes perto do gene que fez com que o mario """"""""""morresse"""""" <- é assim que escreve
	local local_mutation_size = math.random(1,local_mutation_range)
	if(candidate[1].mutation_point > local_mutation_size )then
		--mutaçao local
		for j= candidate[1].mutation_point -local_mutation_size ,candidate[1].mutation_point  do
			candidate[1].genoma[j] = {}
			candidate[1].genoma[j] = generate_gene()
		end
	else
		--se ele morrer muito no começo mutar todos os gene do começo até o ponto de mutaçao
		for j= 1 ,candidate[1].mutation_point do
			candidate[1].genoma[j] = {}
			candidate[1].genoma[j] = generate_gene()
		end
	end
end

-- funçao que faz um Algoritimo Genetico tradicional com a populaçao
-- sempre mantendo o melhor individuo vivo
local function breed_population( )
    local offspring = {}
    local k = 1
    local mother
    local father

    --salvando a populaço
    for i = 1, pop_size do
        offspring[i] = {}
        offspring[i] = candidate[i]
    end

    for i = 0.2*pop_size, pop_size do
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
end

-- funçao que pega o primeiro individuo (o gene modelo) e apartir dele 
-- produz uma populaçao de individuos com pouca diferença do gene modelo 
local function generate_messiah_chuildren()
	--alterando o estado atual do tamanh da populaçao
	pop_size = 20
	--gerando os filhos do Gene modelo, começando em 2 pois o 1 é o gene modelo que tem que ficar vivo
	for i=2, pop_size do
		candidate[i] = {}
		candidate[i].genoma = {}
		candidate[i].fitness = 0.0
		candidate[i].mutation_point= -1
		for j=1, genoma_size do
			candidate[i].genoma[j] = {}
			if(math.random(1,100) > MutationSize) then
				candidate[i].genoma[j] = candidate[1].genoma[j]
	    	else
	    		candidate[i].genoma[j] = generate_gene()
			end
	    end
	end
end

function print_buttons()

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

function display_status()

	gui.text(0, 20, "Fitness: " .. fitness())
	gui.text(0, 40, "Times left: " .. get_level_time())
	gui.text(0, 60, "Mario x: " .. memory.read_u16_le(PLAYER_POS_ADDRESS))
	gui.text(0, 80, "Score: " .. get_score())
	print_buttons()
end

--funçao que escreve o melhor fitness no arquivo
--local function write_bast(candidate)
--	file = io.open(path, "a")
--	file:write("best fitness: " .. candidate.fitness)
--	file:close()
--end


-- Fitness weights
weight1 = 0.3
weight2 = 0.2
weight3 = 0.3
clear = 1000

-- IsDumb Vars
MAX_XIS = 0 -- Max X reached
dumb_counter = 0 -- Time counter to check if it is advancing
LAST_GROUND = 0

-- AG rates
mutation_size = 5
mutation_chance = 20
local_mutation_size = 1
local_mutation_range = 10
max_generation = 400
genoma_size = 500
pop_size = 1

candidate = {}

-- NOTE: em portugues, 'messiah', em ingles 'messiah'
-- 'messia' non ecziste
create_Messiah()
found_messiah = false

seed = os.time()
math.randomseed(seed) -- eh bom usar seed que nao fosse o tempo soh pa saber ql a seed
-- uguu~  eu uso a seed que eu quiser comentario imbecil... nao mimdiga o qui fazer


-- Database var
path = "mario_seed.txt"
file = io.open(path, "a")
file:write("seed: " .. seed .. "\n")
file:close()

-- Dar load em save slot tende a buggar o emulador
-- savestate.loadslot(7)
-- savestate.saveslot(7)

-- Recomendado usar custom save
saveFile = "init_simulation.State"

savestate.save(saveFile)
savestate.load(saveFile)

emu.limitframerate(false)

--------------------------------------------------
--												--
-- MAIN SIMULATION LOOP							--
--												--
--------------------------------------------------

-- Generation loop
for	i = 1, max_generation do

	-- Test each candidate
	for j = 1, pop_size do

		-- print("Testando individuo " .. j)
		
		local movimento = 1
		
		savestate.load(saveFile)
		memory.write_u24_le(SCORE_ADDRESS, 0)-- Reset score to 0

		-- quanicagesimo setimo filho sera dalse
		fim = false
		MAX_XIS = 0
		dumb_counter = 0
		LAST_GROUND = 0

		--loop da simulaçao
		while not fim do
			get_mario_pos()
			
		    -- display_status()

			joypad.set(candidate[j].genoma[movimento], 1)

			if (emu.framecount()%60 == 0) or ( (emu.framecount()%20 == 0) and (should_move()) ) then
				
				movimento = movimento + 1
			end

			 
			if is_dumb() or is_he_deaded_yet() then
				fim = true
				candidate[j].fitness = fitness()
				candidate[j].mutation_point = movimento
			elseif level_end() then
				fim = true
				candidate[j].fitness = fitness() + clearBonus -- bonus por termianr o level
				-- Create pop from messiah
				if not found_messiah then
					generate_messiah_chuildren()
				end
				found_messiah = true
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

	if not found_messiah then
		Finding_Messiah()
	else
		breed_population()
	end
	-- reproduzir a populaçao
end
------ dalse.... kd vc???
