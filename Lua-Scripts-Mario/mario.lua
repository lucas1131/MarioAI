--Author Pasky13

--Mario
local mariox = 0x94
local marioy = 0x96
local mtype = 0x19
local marioside = 0x76

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
	
	_G MARIO_XIS
	_G MARIO_YPSILON

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

    return player_pos, get_level_time()
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

    local TIMER_ADRESS = 0x7E13D6

    if (memory.read_u16_le(TIMER_ADRESS) == 0x49) then
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

    -- gui.text(0, 150,(math.floor(x/0x10)*0x1B0).."  "..(y*0x10).."  "..(x%0x10)..".."..(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10))
    return memory.readbyte(0x1C800 + math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10)
end

emu.limitframerate(true)

Pop = 300
MutationRate = 0.1
MutationChance = 0.2
CrossoverChance = 0.5

weight1 = 0.8
weight2 = 0.2
clear = 1000

inputs = {Right = true}
travelDistance = 0
timeLeft = 0

while true do
    
	-- load_state()

    mario()
    objects()
    invulns()
    projectiles()

    get_level_time()
    print_buttons()
    get_tile()

    marioState = 0x7E0071 -- ANIMATION 0x00 livre 0x09 - morrendo

    -- 7E0100 - GAMESTATE http://www.smwiki.net/wiki/RAM_Address/$7E:0100
    -- 7E13D6 - Timer de fim de fase (fica em 0x50 durante a fase toda)
    memory.usememorydomain("System Bus")
    if (memory.read_u8(marioState) == 0x09) then

        gui.text(0,20, "DEATH MY OLD FRIEND")

    	travelDistance, timeLeft = unpack{fitness()}
    	-- fitness[i] = travelDistance*weight1 + timeLeft*weight2
    end

    if (level_end()) then
    	gui.text(0, 20, "VC EH O BIXAO MERMO Q BLAZER")
    	travelDistance, timeLeft = unpack{fitness()}
    	-- fitness[i] = travelDistance*weight1 + timeLeft*weight2 + clear
	end

    emu.frameadvance()
end
