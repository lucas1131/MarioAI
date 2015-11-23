-- Author Pasky13

-- Mario
local mariox = 0x94
local marioy = 0x96
local mtype = 0x19
local marioside = 0x76

-- SPRITES KEYS
YOSHI = 0x35
YOSHI_EGG = 0x2C
BABY_YOSHI = 0x2D
WIGGLER = 0x86
KOOPA_SHELLS_START = 0xDA
KOOPA_SHELLS_END = 0xDD
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
PLAYER_STATE_ADDRESS = 0x7E0071
PLAYER_POS_ADDRESS = 0x7E00D1
TIMER_ADDRESS = 0x7E13D6
GROUNDED_ADDRESS = 0x7E0072
ENEMY_X_BASE_ADDRESS = 0xE4
ENEMY_y_BASE_ADDRESS = 0xD8
PAGE_X_BASE_ADDRESS = 0x14E0
PAGE_Y_BASE_ADDRESS = 0x14D4
OBJECT_TYPE_ADDRESS = 0x9E

-- Camera
local camx = 0x1A
local camy = 0x1C

-- Object Addresses
local boxpointer = 0x1662
local xoffbase = 0x01b56c
local yoffbase = 0x01b5e4
local xradbase = 0x01b5a8
local yradbase = 0x01b620
local oactive = 0x14C8

-- Invulnerable objects (ghost rings etc...)
local inv_ybase = 0x1E02
local inv_xbase = 0x1E16
local inv_ypage = 0x1E2A
local inv_xpage = 0x1E3E
local itype = 0x1892

-- Ghost snake
local ghosn_type = 0x17F0
local ghosn_xbase = 0x1808
local ghosn_xpage = 0x18EA
local ghosn_ybase = 0x17FC
local ghosn_ypage = 0x1814

-- Ghost ship ghosts
local ghosh_type = 0x1892
local ghosh_xbase = 0x1E16
local ghosh_xpage = 0x1E3E
local ghosh_ybase = 0x1E02
local ghosh_ypage = 0x1E2A

-- Projectiles
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

--------------------------------------------------
--												--
-- NOSSA PARTE									--
--												--
--------------------------------------------------

-- Get tempo restante do level
local function get_level_time()

    local time_hundred = 0x7E0F31
    local time_dec = 0x7E0F32
    local time_unit = 0x7E0F33

    memory.usememorydomain("System Bus")

    local times = (100 * memory.read_u8(time_hundred) + 10 * memory.read_u8(time_dec) + memory.read_u8(time_unit))

    return times
end

-- Calculo da fitness
--
-- (distancia*peso1 + tempoRestante*peso2 ?(+ score*peso3) + lvlCleared)
-- Objetivo: maximizar a funcao fitness

weight1 = 0.8
weight2 = 0.2
clear = 1000
local function fitness()

    memory.usememorydomain("System Bus")

    local player_posX = memory.read_u16_le(PLAYER_POS_ADDRESS)

    return player_posX*weight1 + get_level_time()*weight2 -- + score
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

-- Verifica se chegou no fim da fase
local function level_end()

    memory.usememorydomain("System Bus")

    clearBonus = 0


    if (memory.read_u8(TIMER_ADDRESS) == 0x49) then
        clearBonus = 1000
        return true
    else
    	clearBonus = 1000
        return false
    end
end

--verifica se esta morrendo
function is_he_deaded_yet()
	
	memory.usememorydomain("System Bus")
	
	if (memory.read_u8(PLAYER_STATE_ADDRESS) == 0x09) then
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
	else
		--se ele estiver mudando de altura ta deboas
		if (is_grounded()) then
			if (MARIO_YPSILON ~= LAST_GROUND) then
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
					dumb_counter = 10 --segundos de esperteza
				end
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

-- Get se o title no offset (x, y) e rigido ou nao
function get_tile(offset_X, offset_Y)

    memory.usememorydomain("WRAM")

    local x = math.floor((MARIO_XIS + offset_X + 8)/16)
    local y = math.floor((MARIO_YPSILON + offset_Y)/16)

    local screenX = MARIO_XIS - memory.read_s16_le(0x1A)
    local screenY = MARIO_YPSILON - memory.read_s16_le(0x1C)
    local off = 8

    gui.drawBox(screenX+offset_X, screenY+offset_Y, screenX+offset_X+off, screenY+offset_Y-off, 0xFFFFFFFF, 0x45FFFFFF)

    -- gui.text(0, 150,(math.floor(x/0x10)*0x1B0).."  "..(y*0x10).."  "..(x%0x10)..".."..(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10))
    return memory.readbyte(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10)
end

function is_hostile(key)

	-- Enemies
	if key == WIGGLER then
		return true
	end
	if key >= KOOPA_SHELLS_START and key <= KOOPA_SHELLS_END then
		return true
	end

	-- Other things
	if key == YOSHI then
		return false
	end
	if key == YOSHI_EGG then
		return false
	end
	if key == BABY_YOSHI then
		return false
	end
	if key == KEYHOLE then
		return false
	end
	if key == UNUSED then
		return false
	end
	if key == UNUSED2 then
		return false
	end
	if key == LVL_MSG then
		return false
	end
	if key == COIN then
		return false
	end
	if key == P_SWITCH then
		return false
	end
	if key == SPRINGBOARD then
		return false
	end
	if key == THROW_BLOCK then
		return false
	end
	if key >= TITLES_START and key <= TITLES_END then
		return false
	end
	if key >= USELESS_START and key <= USELESS_END then
		return false
	end
	if key >= PICKUP_START and key <= PICKUP_END then
		return false
	end
	if key >= USELESS_2_START and key <= USELESS_2_END then
		return false
	end

	return true
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
    
    -- gui.drawBox(screenX+target_x, screenY+target_y, screenX+target_x+off, screenY+target_y-off, 0xFFFF0000, 0x30FFFFFF)
    gui.drawBox(screenX+target_x, screenY+target_y, screenX+target_x+off, screenY+target_y-off, 0xFFFFA0A0, 0x45FFA0A0)

	for i = 0, oend do

		objKey = mainmemory.read_u8(OBJECT_TYPE_ADDRESS + i)

		if is_hostile(objKey) then

			enemyX = mainmemory.read_u8(ENEMY_X_BASE_ADDRESS + i) + (mainmemory.read_u8(PAGE_X_BASE_ADDRESS + i) * 256) - mainmemory.read_u16_le(camx)
			enemyY = mainmemory.read_u8(ENEMY_y_BASE_ADDRESS + i) + (mainmemory.read_u8(PAGE_Y_BASE_ADDRESS + i) * 256) - mainmemory.read_u16_le(camy)
			
			gui.drawBox(enemyX, enemyY-yoffset1, enemyX+offset, enemyY+yoffset2, 0xFF6e002d, 0x106e002d)
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

--funaçoq ue retorn aleatoriamente um valor true ou false
local function random_bool()
	return (math.random(1, 10) > 5)
end

SEED = os.time()
math.randomseed(SEED)

max_generation =20
pop_size = 10
genoma_size = 1200

--criar a populaçao
candidate = {}
new_gene = {}

function generate_gene()

	gene = {}

	gene.A = random_bool()
	gene.B = random_bool()
	gene.X = random_bool()
	gene.Y = random_bool()
	gene.Up = false --random_bool()
	gene.Down = false --random_bool()
	gene.Right = true --random_bool()
	gene.Left = false --random_bool()

	return gene
end

for i=1, pop_size do

    candidate[i] = {}
    candidate[i].genoma = {}
    candidate[i].fitness = 0.0

    for j=1, genoma_size do

		candidate[i].genoma[j] = generate_gene()
    end
end

--[["pritando a populaçao"
for i=1, pop_size do
	print("candidate[",i,"]")
	for j=1, genoma_size do
    	print("gene[",j,"]=",candidate[i].genoma[j].A)
		--print(candidate[i].genoma[j].B)
	end
end]]

savestate.load("savedajesscica.extensaoaki")
savestate.save("savedajesscica.extensaoaki")

--------------------------------------------------
--												--
-- MAIN SIMULATION LOOP							 --
--												--
--------------------------------------------------

emu.limitframerate(true)

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
		print("individuo[", j, "]")

		while not fim do
			mario()
			get_level_time()
	    	print_buttons()

	    	-- Display time
    	    gui.text(0,40, "Times left: " .. get_level_time())

    	    -- Display position
			gui.text(0,60, "Mario x: " .. memory.read_u16_le(PLAYER_POS_ADDRESS))

    	    -- Rigid blocks getters
			gui.text(10, 80,  get_tile(32, 0	))
			gui.text(10, 100, get_tile(32, 24	))
			gui.text(10, 120, get_tile(32, 48	))
			gui.text(30, 80,  get_tile(64, 0	))
			gui.text(30, 100, get_tile(64, 24	))
			gui.text(30, 120, get_tile(64, 48	))
			gui.text(50, 80,  get_tile(96, 0	))
			gui.text(50, 100, get_tile(96, 24	))
			gui.text(50, 120, get_tile(96, 48	))

			-- Enemies getters
			gui.text(10, 150, get_enemy(32, 0	))
			gui.text(10, 170, get_enemy(32, 24	))
			gui.text(10, 190, get_enemy(32, 48	))
			gui.text(30, 150, get_enemy(64, 0	))
			gui.text(30, 170, get_enemy(64, 24	))
			gui.text(30, 190, get_enemy(64, 48	))
			gui.text(50, 150, get_enemy(96, 0	))
			gui.text(50, 170, get_enemy(96, 24	))
			gui.text(50, 190, get_enemy(96, 48	))

			joypad.set(candidate[j].genoma[movimento], 1)

			if (emu.framecount()%20 == 0) then
				movimento = movimento + 1
			end

			if (is_he_deaded_yet() or level_end()) then
				fim = true
				fitneis = fitness()
			end

	    emu.frameadvance()
		end
	end
	--[[selecionar a populaçao
	for i=1, pop_size do
		select = i,do
		for 0

			end
		end]]

	--reproduzir a populaçao
end
