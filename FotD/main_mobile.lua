require("AnAL")
require("movement")
local lastxpgain


function love.load()


--fonts
pixelfont = love.graphics.newImageFont("fonts/pixelfont.png"," abcdefghijklmnopqrstuvwxyz" .."ABCDEFGHIJKLMNOPQRSTUVWXYZ0" .."123456789.,!?-+/():;%&`'*#=[]\"")
verdana8 = love.graphics.newFont("fonts/verdana.ttf", 8)
verdana48 = love.graphics.newFont("fonts/verdana.ttf", 48)
verdana36 = love.graphics.newFont("fonts/verdana.ttf", 36)
verdana18 = love.graphics.newFont("fonts/verdana.ttf", 18)
twotrees48 = love.graphics.newFont("fonts/TwoTrees.ttf", 48)
twotrees36 = love.graphics.newFont("fonts/TwoTrees.ttf", 36)
twotrees18 = love.graphics.newFont("fonts/TwoTrees.ttf", 18)

programname = "Fear of the Dark"
love.graphics.setCaption( programname )


--game init var
gamemode = "splash"

--game vars
obtaineditemids={}
dbg=""

--saves
savedgames=nil

--splash
splashsrc = love.graphics.newImage("pictures/splash.png")
splash = newAnimation(splashsrc, 280, 280, 0.1, 0)
splash:seek(1)
splashcount=0

--vidya settings
gw,gh = 800,600
sw,sh = gw,gh


--mainmenu
mainmenuindex = 1
mainmenuentries={"Start","Load","Options","Exit"}
mainmenumax = table.maxn(mainmenuentries)
bgimg = love.graphics.newImage("pictures/menu/bg.png")

--pausemenu
pausemenuindex = 1
pausemenuentries={"Continue","Save","Options","Main Menu"}
pausemenumax = table.maxn(pausemenuentries)

--pausemenu
videomenuindex = 1
videomenuentries={"Video Mode: ","Resolution (Press Enter to Edit): ","Full Screen","Back"}
videomenumax = table.maxn(videomenuentries)

--optionsmenu
optionsmenuindex = 1
optionsmenuentries={"Volume: " .. math.round(love.audio.getVolume( )*100),"Video Settings","View Controls","Return"}
optionsmenumax = table.maxn(optionsmenuentries)
camefrom=nil

--sound
menubgm = love.audio.newSource("sound/fotd.ogg")

--intro
controlsimg = love.graphics.newImage("pictures/menu/controls.png")
showcontrols=false
intro={}
introi=1

--overworld
worldTime=50 --higher the darker (127 the darkest)
itemimg={}
itemlist={}

--camera
cameraoffsetx=0
cameraoffsety=0


--npcs
npcimg={}
npcimgsrc={}

--mobs
mobsrcn = love.graphics.newImage("mobs/spriten.png")
mobsrcs = love.graphics.newImage("mobs/sprites.png")
mobsrce = love.graphics.newImage("mobs/spritee.png")
mobsrcw = love.graphics.newImage("mobs/spritew.png")
mobspriten = newAnimation(mobsrcn, 36, 48, 0.1, 0)
mobsprites = newAnimation(mobsrcs, 36, 48, 0.1, 0)
mobspritee = newAnimation(mobsrce, 36, 48, 0.1, 0)
mobspritew = newAnimation(mobsrcw, 36, 48, 0.1, 0)
moblist=nil
mobpatroly={}
mobpatrolx={}
mobpatroldirection={}

--collision
collnum=nil
collrect={}


--protag
protagss = love.graphics.newImage("pictures/sprites/protagss.png")
protagbattless = love.graphics.newImage("pictures/sprites/battle.png")
protag = newAnimation(protagss, 36, 48, 0.1, 0)
protagbattle = newAnimation(protagbattless, 75, 72, 0.1, 0)
protagprompt = love.graphics.newImage("pictures/sprites/prompt.png")
protagpic =  love.graphics.newImage("pictures/sprites/picture.png")
protagHeight = 45
protagWidth = 26
protagX=0
protagY=0
calcx=0
calcy=0

--protagstats
protagDMG=1
protagLVL=1
protagXP=0
protagHP=10
protagMA={"","","",""}

--battlemode
targetprompt = love.graphics.newImage("pictures/battle/targetprompt.png")
battlebg = love.graphics.newImage("pictures/battle/battlebackground.png")
battlestats = {}
selectedenemy=1
numenemies=0
battlesprites={}
mobtofight=0
mainbattleoptions={"Attack", "Defend", "Magic", "Run"}
magicbattleoptions={protagMA[1], protagMA[2], protagMA[3], protagMA[4]}
selectedbattleoption=1
enemyattacking=nil


--notifications
notificationfader=255
notificationstr=nil

--objectivesGUI
showobjectives=false
objectiveid={}
objectives={}
completedobjectives={}
n = table.maxn(objectives)
objectivesindex=1

--chatGUI
showchatscreen=false
chattingwith = "null"
npcchatpicture = null
npcscript = "null"
chatoverlay = love.graphics.newImage("pictures/chat/chatoverlay.png")
npcchatindex = 1

--msgGUI
msgoverlay = love.graphics.newImage("pictures/msg/msgoverlay.png")
showmsgscreen=false
showmsgscreen=false

--inventoryGUI
showinventory=false
inventoryoverlay = love.graphics.newImage("pictures/inventory/inventoryoverlay.png")
inventoryindex = 1
inventory={}

--rewardGUI
rewardbg =  love.graphics.newImage("pictures/battle/rbg.png")
cancontinue=false
rii=1
ri=1


--movement


loadintro(27)
loadmap("Asgarourhouse2","246","322","148","64")
newobjective("001")
love.audio.setVolume(0.3)
debugmode=true


if debugmode==true then
gamemode="gameplay"
love.audio.setVolume(0)
end

end

function loadintro(num)
	i=1
	while i < num+1 do
		intro[i] = love.graphics.newImage("pictures/intro/"..i..".png")
		i=i+1
	end

end

function love.update(dt)
	--fps control
	
	if gamemode == "menu" or gamemode== "gameoptions" or gamemode== "videomenu" or gamemode== "splash" or gamemode=="intro" then
		if menubgm:isPaused() == true or menubgm:isStopped() == true then
			love.audio.play(menubgm)
			menubgm:setLooping(true)
		end
	else
		love.audio.stop(menubgm)
	end

	if gamemode == "splash" and winCreated==true then
		splash:update(dt)
	end
	
	if gamemode == "gameplay" and showchatscreen==false and showinventory==false and showobjectives==false then
		movementcontrols()
		if okaytomove==true or okaytoanim==true then
			protag:update(dt)
		end
		okaytomove=false
		okaytoanim=false
		
		if moblist~=nil and table.maxn(moblist) > 0 then
			mobspriten:update(dt)
			if mobspriten:getCurrentFrame() > 3  then
				mobspriten:seek(1)
			end
			mobsprites:update(dt)
			if mobsprites:getCurrentFrame() > 3 then
				mobsprites:seek(1)
			end
			mobspritee:update(dt)
			if mobspritee:getCurrentFrame() > 3 then
				mobspritee:seek(1)
			end
			mobspritew:update(dt)
			if mobspritew:getCurrentFrame() > 3 then
				mobspritew:seek(1)
			end	
		end
		elseif gamemode == "rewardscreen" then
		if rii > 200 then
			if lastxpgain-ri >= 0 then
				lastxpgain=lastxpgain-1
				protagXP=protagXP + 1
				rii=1
			else
				cancontinue=true
				if protagXP>=(protagLVL*1000)*1.25 then				--if my xp reaches level limit
					levelup()
				end
			end
		else
			rii=rii+40
		end
	elseif gamemode=="loadscreen" then
		if savedgames==nil then
			sdirexists=love.filesystem.exists("saves")
			if sdirexists==false then
				love.filesystem.mkdir("saves")
				savedgames={}
			else
				savedgames=love.filesystem.enumerate("saves")
				n=table.maxn(savedgames)
				savedgames[n+1]="Return"
			end
		end
	elseif gamemode=="battle" then
		if battlestats==nil or table.maxn(battlestats)==0 then
			ixy=stringsplit(moblist[mobtofight],",")
			love.filesystem.load("mobs/" ..ixy[1].. "/stats.lua")()
			n = math.random(1,3)
			i=1
			while i < n+1 do
				battlestats[i]={}
				battlestats[i][1]="Skeleton"
				battlestats[i][2]=mobhp
				battlestats[i][3]=mobhp
				battlestats[i][4]=mobatk
				i=i+1
			end
			numenemies = table.maxn(battlestats)
			battleoptions=2
			playerturn=true
		end
		if playerturn==false then
			n = table.maxn(battlestats)
			i = math.random(1,n)
			enemyattacking=i
			if battlestate=="attack" then
				protagHP=protagHP-mobatk
			elseif battlestate=="defend" then
				protagHP=protagHP-(mobatk/2)
			end
			
			if protagHP<=0 then
				protagDeath()
			end
			
			playerturn=true
			battlestate="main" 
		end
	end
	
	dbg=" OFFX: " .. cameraoffsetx .. " OFFY: " ..cameraoffsety .. " CALCX " .. calcx .. " CALCY " .. calcy
	
end

function loadmap(mapname,xxx,yyy,offx,offy)
	collrect={}
	npcimg={}
	love.filesystem.load("maps/" ..mapname.. "/map.lua")()
	map = love.graphics.newImage("maps/" ..mapname.. "/background.png")
	collisionmap = love.image.newImageData("maps/" ..mapname.. "/collision.png")
	mapoverlay = love.graphics.newImage("maps/" ..mapname.. "/overlay.png")
	if love.filesystem.exists( "maps/" ..mapname.. "/lights.png" ) == true then
		islightmap=true
		lightmap = love.graphics.newImage("maps/" ..mapname.. "/lights.png")
	else
		islightmap=false
	end
	protagX=xxx+0
	protagY=yyy+0
	cameraoffsetx=offx
	cameraoffsety=offy
	curmap = mapname
	calcx=protagX-cameraoffsetx 
	calcy=protagY - cameraoffsety 
	

	
	if itemlist~=nil then
		i = 1
		n=table.maxn(itemlist)
		while i < n+1 do
			nn=table.maxn(collrect)
			ixy=stringsplit(itemlist[i],",")
			if obtaineditemids[ixy[4]+0]==nil then
				itemimg[i]=love.graphics.newImage("items/" ..ixy[1].. "/sprite.png")
				collrect[nn+1]={}
				collrect[nn+1][1]=ixy[2]
				collrect[nn+1][2]=ixy[3]
				collrect[nn+1][3]=ixy[2]+20
				collrect[nn+1][4]=ixy[3]+20
				collrect[nn+1][5]="item"
			end
			i=i+1
		end
	end
	
	if npclist~=nil then
		i = 1
		n=table.maxn(npclist)
		while i < n+1 do
			nn=table.maxn(collrect)
			ixy=stringsplit(npclist[i],",")
			npcimgsrc[i]=love.graphics.newImage("npcs/" ..ixy[1].. "/sprite.png")
			npcimg[i]=newAnimation(npcimgsrc[i], 36, 48, 0.1, 0)
			npcimg[i]:seek(8)
			collrect[nn+1]={}
			collrect[nn+1][1]=ixy[2]
			collrect[nn+1][2]=ixy[3]-20
			collrect[nn+1][3]=ixy[2]+36
			collrect[nn+1][4]=ixy[3]+48
			collrect[nn+1][5]="npc"
			i=i+1
		end
	end
end

function savestate()
file = io.open("savestate.lua.txt", "w")
--find out how to note which booleons are false in an array, maybe arraydump
--file:write("position={"..curmap..","..protagX..","..protagY.."}\r\nobtaineditemids={"..implode(",",obtaineditemids).."}")
file:flush()
file:close()
end

function loadstate()
file = io.open("savestate.lua.txt", "r")

file:close()
end

function implode(d,p)
  local newstr
  newstr = ""
  if(#p == 1) then
    return p[1]
  end
  for ii = 1, (#p-1) do
    newstr = newstr .. p[ii] .. d
  end
  newstr = newstr .. p[#p]
  return newstr
end


function math.round(num)
    return math.floor(num+0.5)
end

function love.keyreleased( key )
	if gamemode== "menu" then
		if key == "up"  or key=="w" then
			mainmenuindex=mainmenuindex-1
			
		elseif key == "down" or key=="s" then
			mainmenuindex=mainmenuindex+1
			
		elseif key=="return" or key=="enter" then
			if mainmenuindex==1 then
				gamemode="intro"
			elseif mainmenuindex==2 then
				gamemode="loadscreen"
			elseif mainmenuindex==3 then
				gamemode="gameoptions"
				camefrom="mainmenu"
			elseif mainmenuindex==4 then
				os.exit()
			end
		end
		if mainmenuindex>mainmenumax then
			mainmenuindex=1 
		elseif mainmenuindex==0 then
			mainmenuindex=mainmenumax
		end
	elseif gamemode== "pausemenu" then
		if key == "up"  or key=="w" then
			pausemenuindex=pausemenuindex-1
			
		elseif key == "down" or key=="s" then
			pausemenuindex=pausemenuindex+1
			
		elseif key=="escape" then
			gamemode="gameplay"
		elseif key=="return" or key=="enter" then
			if pausemenuindex==1 then
				gamemode="gameplay"
			elseif pausemenuindex==2 then
				--gamemode="save"
				savestate()
			elseif pausemenuindex==3 then
				gamemode="gameoptions"
				camefrom="pausemenu"
			elseif pausemenuindex==4 then
				gamemode="menu"
			end
		end
		if pausemenuindex>pausemenumax then
			pausemenuindex=1
		elseif pausemenuindex==0 then
			pausemenuindex=pausemenumax
		end
		
		elseif gamemode== "videomenu" then
			if key == "up"  or key=="w" then
				videomenuindex=videomenuindex-1
				
			elseif key == "down" or key=="s" then
				videomenuindex=videomenuindex+1
				
			elseif key=="escape" then
				gamemode="optionsmenu"
			elseif editmode and videomenuindex==2 then
				if key == 'backspace' then
					table.remove(typed)	
					resstr = table.concat(typed)	
					videomenuentries[2]="Resolution (Press Enter to Edit): " .. resstr		
					res.set(mode,gw,gh,sw,sh)					
				elseif key == 'return' then
					local res_string    = table.concat(typed)
					local new_sw,new_sh = res_string:match('(%d+)x(%d+)')
					new_sw,new_sh       = tonumber(new_sw),tonumber(new_sh)
					if new_sw and new_sh then 
						local _,_,fullscreen = lg.getMode()
						lg.setMode(new_sw,new_sh,fullscreen)
						sw,sh = new_sw,new_sh
						res.set(mode,gw,gh,sw,sh)
					end
					typed    = {''}
					editmode = false
					res.set(mode,gw,gh,sw,sh)
				else
					table.insert(typed,key)
					resstr = table.concat(typed)
					videomenuentries[2]="Resolution (Press Enter to Edit): " .. resstr
					res.set(mode,gw,gh,sw,sh)
				end
				elseif key=="return" or key=="enter" then
					if videomenuindex==1 then
						if mode == "center" then
							mode = "fit"
						elseif mode == "fit" then
							mode = "stretch"
						elseif mode == "stretch" then
							mode = "nearest"
						else
							mode = "center"
						end
						res.set(mode,gw,gh,sw,sh)
						videomenuentries[1]="Video Mode: " .. mode				
					elseif videomenuindex==2 then
						editmode = not editmode
						if not editmode then
							typed = {''}
						end	
					elseif videomenuindex==3 then
						lg.toggleFullscreen()
					elseif videomenuindex==4 then
						gamemode="gameoptions"
					end
				end
		
		if videomenuindex>videomenumax then
			videomenuindex=1
		elseif videomenuindex==0 then
			videomenuindex=videomenumax
		end

	
	elseif gamemode == "intro" then
		if key=="return" or key=="enter" then
			introi=introi+1
		end
	elseif gamemode == "rewardscreen" then
		if key=="return" and cancontinue==true or key=="enter" and cancontinue==true then
			ri=1
			rii=1
			cancontinue=false
			gamemode="gameplay"
		end
	elseif gamemode== "battle" then
		if playerturn==true then
			if battlestate=="main" then
				if key=="up" or key=="down" or key=="w" or key=="s" then
					if key=="up" or key=="w" then
						selectedbattleoption=selectedbattleoption+1
					elseif key=="down" or key=="s" then
						selectedbattleoption=selectedbattleoption-1
					end
					if selectedbattleoption<1 then
						selectedbattleoption=4
					elseif selectedbattleoption>4 then
						selectedbattleoption=1
					end	
				else
					if key=="enter" or key=="return" then
						if selectedbattleoption==1 then
							battlestate="attack"
						elseif  selectedbattleoption==2 then
							battlestate="defend"
							playerturn=false
						elseif  selectedbattleoption==3 then
							battlestate="magic"
						elseif  selectedbattleoption==4 then
							attemptRun()
						end
						selectedbattleoption=1
					end
				end
			elseif battlestate=="attack" then
				if battlestats~=nil and table.maxn(battlestats)>0 then
					if key=="return" or key=="enter" then
						damage(selectedenemy)
					elseif key=="up" or key=="w" then
						selectedenemy=selectedenemy-1
						if battlestats[selectedenemy] == nil then
						selectedenemy =selectedenemy-1
						end
						if selectedenemy<1 then
							selectedenemy=table.maxn(battlestats)
						end		
					elseif key=="down" or key=="s" then
						selectedenemy=selectedenemy+1
						if selectedenemy>table.maxn(battlestats) then
							selectedenemy=1
						end
						while battlestats[selectedenemy] ==nil do
							selectedenemy = selectedenemy+1
						end
					end
				end
			elseif battlestate=="defend" then
				
			elseif battlestate=="magic" then
				if protagMA[1]=="" and protagMA[2]=="" and protagMA[3]=="" and protagMA[4]==""  then
					battlestate="main"
				end
			end
		end

	
	elseif gamemode == "gameplay" then
		
		if showinventory==true then
		n = table.maxn(inventory)
			if key == "up"  or key=="w" then
				if inventoryindex==1 then
					inventoryindex=n
				else
					inventoryindex=inventoryindex-1
				end
				
			elseif key == "down" or key=="s" then
				if inventoryindex==n then
					inventoryindex=1
				else
					inventoryindex=inventoryindex+1
				end
				
			end
		elseif showobjectives==true then
		n = table.maxn(objectives) + table.maxn(completedobjectives)
			if key == "up"  or key=="w" then
				if objectivesindex==1 then
					objectivesindex=n
				else
					objectivesindex=objectivesindex-1
				end
				
			elseif key == "down" or key=="s" then
				if objectivesindex==n then
					objectivesindex=1
				else
					objectivesindex=objectivesindex+1
				end
				
			end
		end
		
		
		if key=="escape" then
			gamemode="pausemenu"
		elseif key =="tab" then
			if showinventory == true then
				showinventory=false
			else
				showinventory=true
			end
		elseif key =="q" then
			if showobjectives == true then
				showobjectives=false
			else
				showobjectives=true
			end
		elseif key =="enter" or key =="return" then
			if showmsgscreen==true then
				showmsgscreen=false
			elseif showchatscreen==true then
			maxnpcchatindex = table.maxn(npcscript) -1
				if npcchatindex+2 > maxnpcchatindex then
						showchatscreen=false
						npcchatindex=1
					else
						npcchatindex=npcchatindex+2
				end
			elseif interactable~="null" then
				interact(interactable)
			end
		end
		
	elseif gamemode == "gameoptions" then

	
		if key == "up"  or key=="w" then
			if showcontrols==false then
				optionsmenuindex=optionsmenuindex-1
			end
			
		elseif key == "down" or key=="s" then
			if showcontrols==false then
				optionsmenuindex=optionsmenuindex+1
			end
			
		elseif optionsmenuindex==1 then
			curvolume = love.audio.getVolume( )
			if key == "left" or key=="a" then
				if curvolume <=0.05 then
						love.audio.setVolume(0)
					else
						love.audio.setVolume( curvolume - 0.05 )
				end
			elseif key == "right" or key=="d" then
				if curvolume < 1 then
					love.audio.setVolume( curvolume + 0.05 )
				end
			end
			optionsmenuentries[1]="Volume: " .. math.round(love.audio.getVolume( )*100)
		elseif key=="return" or key=="enter" then
			if optionsmenuindex==2 then
				gamemode="videomenu"
			elseif optionsmenuindex==3 then
				if showcontrols==true then
					showcontrols=false
				elseif showcontrols==false then
					showcontrols=true
				end
			elseif optionsmenuindex==4 then
				if camefrom=="mainmenu" then
					gamemode="menu"
				elseif camefrom=="pausemenu" then
					gamemode="pausemenu"
				end
			end			
		end
		if optionsmenuindex>optionsmenumax then
			optionsmenuindex=1
		elseif optionsmenuindex==0 then
			optionsmenuindex=optionsmenumax
		end
	end
end

function interact(obj)
	if obj~=nil then
		if direction=="north" then
			dirtoface=8
		elseif direction=="east" then
			dirtoface=11
		elseif direction=="south" then
			dirtoface=2
		elseif direction=="west" then
			dirtoface=5
		end

		ixy=stringsplit(obj,",")
		objtype=ixy[1]
		objnum=ixy[2]+0
		
		if objtype=="npc" then
		npcimg[objnum]:seek(dirtoface)
		ixy=stringsplit(npclist[objnum],",")
		chat(ixy[1])
		
		
		elseif objtype=="item" then
			ixy=stringsplit(itemlist[objnum],",")
			additem(ixy[1])
			obtaineditemids[ixy[4]+0]=false
			itemlist[objnum]=nil
			collrect[collnum]=nil
		end
		
	end
end

function damage(target)
if target==nil then 
	target=1
end
battlestats[target][2] = battlestats[target][2]-protagDMG
if battlestats[target][2] <= 0 then 	 				--if enemy hp reaches 0
	if lastxpgain==nil or lastxpgain==0 then
	lastxpgain = battlestats[target][3]+0	--calc xp to gain
	else
	lastxpgain = lastxpgain + battlestats[target][3]+0	--calc xp to gain
	end
	battlestats[target]=nil        	 					--remove him from array/kill him
	numenemies=numenemies-1
		
	if numenemies==0 then
		moblist[mobtofight]=nil
		gamemode="rewardscreen"
	else
		selectedenemy=selectedenemy+1
		if selectedenemy>table.maxn(battlestats) then
			selectedenemy=1
		end
		while battlestats[selectedenemy] ==nil do
			selectedenemy = selectedenemy+1
		end
	end
end

playerturn=false

end

function attemptRun()

gamemode="gameplay"
moblist[mobtofight]=nil

end

function chat(name)
	chattingwith = name
	npcchatpicture = love.graphics.newImage("npcs/" .. name .. "/picture.png")
	love.filesystem.load("npcs/" ..name.. "/script.lua")()
	love.filesystem.load("objectives/" ..objectiveid.. ".lua")()

	--check objectives table, if any has "talkto" then check the name, and tick it off if it matches
	checkobjectivestring = stringsplit(objectivetype,":")
	if  checkobjectivestring[1] == "talkto" then
		if  checkobjectivestring[2] == name then
			objectivecompleted()
		end
	end
	showchatscreen=true
end

function additem(itemname)
	table.insert(inventory, itemname)
	love.filesystem.load("items/" ..itemname.. "/stats.lua")()
	msgstring = "Gained item: " .. name .. "!"
	checkobjectivestring = stringsplit(objectivetype,":")
	if  checkobjectivestring[1] == "hasitem" then
		if  checkobjectivestring[2] == itemname then
			objectivecompleted()
		end
	end
	showmsgscreen=true
		interactable=nil
end

function removeitem(itemname)
	n=table.maxn(inventory)
	i=1
	while i < n+1 do
		if inventory[i] == itemname then
			inventory[i] = nil
		end
	i=i+1
	end
	if showchatscreen==false then
		love.filesystem.load("items/" ..itemname.. "/stats.lua")()
		msgstring = "Removed item: " .. name .. "!"
		showmsgscreen=true
	end
end

function objectivecompleted()
	n = table.maxn(objectives)
	i=1
	while i < n+1 do
		if objectives[i] == objectiveid then
			table.insert(completedobjectives,objectives[i])
			table.remove(objectives, i)
		end
		i=i+1
	end
	newobjective(nextobj)
end

function newobjective(ToLoad)
	objectiveid=ToLoad
	table.insert(objectives,ToLoad)
	love.filesystem.load("objectives/" ..objectiveid.. ".lua")()
	notification("New Quest - " .. objectivetitle)
end

function notification(text)
notificationstr=text
end

function stringsplit(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function levelup()
protagXP=protagXP-((protagLVL*1000)*1.25)		--remove all used xp
notification("Level up!")						--levelup
protagLVL=protagLVL+1
protagHP=protagLVL*10
end

function love.draw( key )


	if gamemode == "splash" then
		splash:draw(gw/2-(280/2),gh/2-(280/2))
		if splash:getCurrentFrame()==40 then
			gamemode="menu"
		end
	elseif gamemode == "rewardscreen" then
		love.graphics.draw(rewardbg, 0, 0)
		love.graphics.draw(protagpic, 130, 100)
		love.graphics.setFont(pixelfont)
		love.graphics.printf("XP Gain:\r\n" .. lastxpgain, 200, 40, gw, 'center')
		if lastxpgain>0 and rii < 300 then
		love.graphics.printf("1", 200, 50+rii, gw, 'center')
		else
		love.graphics.printf("Press Enter to Continue", 0, 550, gw, 'center')
		end
		love.graphics.printf("Total XP: " .. protagXP, 200, 300, gw, 'center')
	elseif gamemode == "gameplay" then
		love.graphics.setFont(pixelfont)
		
		--draw the actual map
		love.graphics.draw(map, cameraoffsetx, cameraoffsety)
		
		--draw npc sprites (if any)
		
		if npcimg~=nil and table.maxn(npcimg)>0 and npclist~=nil and table.maxn(npclist)>0 then
			i=1
			n=table.maxn(npcimg)
			while i <n+1 do
				ixy=stringsplit(npclist[i],",") 
				npcimg[i]:draw(ixy[2]+cameraoffsetx,ixy[3]+cameraoffsety)
				i=i+1
			end
		end
		
		
		--draw item sprites (if any)
		if itemlist~=nil then
			i = 1
			n=table.maxn(itemlist)
			while i < n+1 do
				ixy=stringsplit(itemlist[i],",")
				if  obtaineditemids[ixy[4]+0]==nil then
				love.graphics.draw(itemimg[i],ixy[2]+cameraoffsetx, ixy[3]+cameraoffsety)
				end
				dbg=dbg .. " " .. ixy[4]
				i=i+1
			end
		end
		
		if debugmode==true then
			if collrect~=nil and table.maxn(collrect)>0 then
				i=1
				n=table.maxn(collrect)
				while i <n+1 do
					love.graphics.rectangle("line",collrect[i][1]+cameraoffsetx,collrect[i][2]+cameraoffsety,collrect[i][3]-collrect[i][1],collrect[i][4]-collrect[i][2])
					i=i+1
				end
			end
		end
		
		--draw mobs (if any)
		if moblist~=nil then
			i=1
			n= table.maxn(moblist)+1
			while i < n do
			
				if moblist[i]~=nil then
					ixy=stringsplit(moblist[i],",")
					
					tempup=ixy[4]+0
					tempdown=ixy[5]+0
					
					if mobpatroly[i]==nil then
						mobpatroly[i]=ixy[3]+0 
						mobpatroldirection[i]=ixy[6]
					elseif mobpatroly[i] < ixy[3] - tempup then --if exceeded the upper limit
						mobpatroldirection[i]="down"
					elseif mobpatroly[i] > ixy[3] + tempdown then --if exceeded the lower limit
						mobpatroldirection[i]="up"
					end
					
					if mobpatrolx[i]==nil then
						mobpatrolx[i]=ixy[2]+0
						mobpatroldirection[i]=ixy[6]
					elseif mobpatrolx[i] < ixy[2] - tempup then --if exceeded the left limit
						mobpatroldirection[i]="right"
					elseif mobpatrolx[i] > ixy[2] + tempdown then --if exceeded the right limit
						mobpatroldirection[i]="left"
					end
					
					if mobpatroldirection[i]=="up" then
						mobpatroly[i]=mobpatroly[i]-1
						x=ixy[2]+cameraoffsetx
						y=mobpatroly[i]+cameraoffsety
						mobspriten:draw(x,y)
					elseif mobpatroldirection[i]=="down" then
						mobpatroly[i]=mobpatroly[i]+1
						x=ixy[2]+cameraoffsetx
						y=mobpatroly[i]+cameraoffsety
						mobsprites:draw(x,y)
					elseif mobpatroldirection[i]=="left" then
						mobpatrolx[i]=mobpatrolx[i]-1
						x=mobpatrolx[i]+cameraoffsetx
						y=ixy[3]+cameraoffsety
						mobspritew:draw(x,y)
					elseif mobpatroldirection[i]=="right" then
						mobpatrolx[i]=mobpatrolx[i]+1
						x=mobpatrolx[i]+cameraoffsetx
						y=ixy[3]+cameraoffsety
						mobspritee:draw(x,y)
					end		
						
					if y+48 > protagY and y < protagY+protagHeight and x+36 > protagX and x < protagX+protagWidth then
						mobtofight=i+0
						battlestate="main"
						gamemode="battle"
					end
				end
				i=i+1
			end
		end
		
		
		--draw the protagonist
		protag:draw(protagX, protagY)
		--if something is interactable show a prompt, ie question mark
		if interactable~=nil then
				love.graphics.draw(protagprompt, protagX, protagY-20)
		end
		
		love.graphics.draw(mapoverlay, cameraoffsetx, cameraoffsety)

		love.graphics.setBlendMode('multiplicative')
		love.graphics.setColor(0,0,0,worldTime)
		love.graphics.rectangle("fill", 0, 0, 800, 600 )
		love.graphics.setColor(255,255,255,worldTime)
		if islightmap==true then
		love.graphics.draw(lightmap, cameraoffsetx, cameraoffsety)
		end
		love.graphics.setColor(255,255,255,255)
		love.graphics.setBlendMode('alpha')
		
		--show notifications
		if notificationstr~=nil then
		love.graphics.setFont(twotrees36)
			love.graphics.printf(notificationstr, 0, 40, 800, 'center')
			notificationfader=notificationfader-1
			if notificationfader == 0 then
				notificationfader=255
				notificationstr=nil
			end
		love.graphics.setFont(verdana18)
		end

		if showchatscreen==true then
			love.graphics.draw(npcchatpicture, 0, 116)
			love.graphics.draw(chatoverlay, 0, 434)
			love.graphics.setColor(0,0,0,255)
			love.graphics.setFont(verdana36)
			love.graphics.printf(chattingwith, 25, 435, 800, 'left')
			love.graphics.printf(npcscript[npcchatindex], 25, 500, 800, 'left')
			love.graphics.printf(npcscript[npcchatindex+1], 25, 550, 800, 'left')
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.setFont(verdana18)
		elseif showmsgscreen==true then
			love.graphics.draw(msgoverlay, 0, 434)
			love.graphics.setColor(0,0,0,255)
			love.graphics.setFont(verdana36)
			love.graphics.printf(msgstring, 25, 500, 800, 'left')
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.setFont(verdana18)
		elseif showinventory==true then
		
			n = table.maxn(inventory)
			love.graphics.draw(inventoryoverlay, 0, 0)
			ix=35
			i=1
			while i <= n do	
				if inventory[i]~=nil then
					if i == objectivesindex then
						love.graphics.setColor(255,201,14,255)
						love.filesystem.load("items/" ..inventory[i].. "/stats.lua")()
						love.graphics.printf(name, 420, 320, 800, 'left')
						love.graphics.printf(description, 405, 350, 800, 'left')
						love.graphics.setColor(255,255,0,255)
						love.graphics.printf(inventoryindex .. " / " .. (n-1), 300, 540, 800, 'left')
						love.graphics.printf(name, 50, ix, 800, 'left')
						love.graphics.setColor(255, 255, 255, 255)
						love.graphics.draw(itemimage, 401, 43)
					else
					love.graphics.setColor(255,255,255,255)
					love.filesystem.load("items/" ..inventory[i].. "/stats.lua")()
					love.graphics.printf(name, 50, ix, 800, 'left')
					end
					
					ix=ix+20
				end
				i=i+1
			end

		elseif showobjectives==true then	
			n = table.maxn(objectives)
			nn = n + table.maxn(completedobjectives)
			love.graphics.draw(inventoryoverlay, 0, 0)
			ix=35
			table.sort(objectives)
			i=1
			while i <= n do	
				if objectives[i]~=nil then
					if i == objectivesindex then
						love.graphics.setColor(255,201,14,255)
						love.filesystem.load("objectives/" ..objectives[i].. ".lua")()
						love.graphics.printf(objectiveid .. " - " .. objectivetitle, 420, 320, 800, 'left')
						love.graphics.printf(objectivedescription, 405, 350, 800, 'left')
						love.graphics.setColor(255, 255, 255, 255)
						love.graphics.draw(objectiveimage, 401, 43)
						love.graphics.setColor(255,255,0,255)
						love.graphics.printf(objectives[i], 50, ix, 800, 'left')
					else
					love.graphics.setColor(255,255,255,255)
					love.graphics.printf(objectives[i], 50, ix, 800, 'left')
					end
					
					ix=ix+20
				end
				i=i+1
			end
			--completed title
			love.graphics.setColor(127,127,127,255)
			love.graphics.printf("	Completed:", 50, ix, 800, 'left')
			ix=ix+20
			j=1
			--completed objectives
			while j <= table.maxn(completedobjectives) do	
				if completedobjectives[j]~=nil then
					if n+j == objectivesindex then
						love.filesystem.load("objectives/" ..completedobjectives[j].. ".lua")()
						love.graphics.printf(objectiveid .. " - " .. objectivetitle, 420, 320, 800, 'left')
						love.graphics.printf(objectivedescription, 405, 350, 800, 'left')
						love.graphics.setColor(255, 255, 255, 255)
						love.graphics.draw(objectiveimage, 401, 43)
						love.graphics.setColor(255,255,0,255)
						love.graphics.printf(completedobjectives[j], 50, ix, 800, 'left')
					else
					love.graphics.setColor(127,127,127,255)
					love.graphics.printf(completedobjectives[j], 50, ix, 800, 'left')
					end		
					ix=ix+20
				end
				j=j+1
			end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf(objectivesindex .. " / " .. (nn), 300, 540, 800, 'left')
		love.graphics.setColor(255, 255, 255, 255)
		end
	elseif gamemode == "battle" then
		if battlestats~=nil and table.maxn(battlestats)>0  then
			love.graphics.draw(battlebg, 0, 0)
			protagbattle:draw(200, 225)
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print("HP: " .. protagHP, 200, 225-20)
			love.graphics.setColor(255, 255, 255, 255)
			n=table.maxn(battlestats)
			i=1
			iy=50
			while i < n+1 do	
				if battlestats[i]~=nil then
					if i == 2 then
						ix = 600
					else
						ix = 550
					end
					love.graphics.setColor(0, 0, 0, 255)
					love.graphics.print("HP: " .. battlestats[i][2], ix-10, iy+50)
					love.graphics.setColor(255, 255, 255, 255)
					if i == selectedenemy and battlestate=="attack" then
						love.graphics.draw(targetprompt, ix, iy-20)
					end
					if playerturn==false then
					
					end
					battlesprites[battlestats[i][1]]:draw(ix, iy)
				end
				i=i+1
				iy=iy+150
			end
			
				love.graphics.draw(msgoverlay, 0, 434)
				love.graphics.setFont(pixelfont)
				i=1
				tmp=nil
				if battlestate=="main" then
					tmp=mainbattleoptions
				elseif battlestate=="attack" then
					tmp={"Attacking...","","",""}
				elseif battlestate=="defend" then
					tmp={"Defending...","","",""}
				elseif battlestate=="magic" then
					if protagMA[1]=="" and protagMA[2]=="" and protagMA[3]=="" and protagMA[4]==""  then
						tmp={"You", "have" ,"no", "Spells!"}
					else
						tmp=magicbattleoptions
					end
				elseif  battlestate=="main" then
					tmp=mainbattleoptions
				end
				while i < 5 do
					if i == 1 then x = 25 elseif i==2 then x=245 elseif i==3 then x=475 else x=665 end
					if i == selectedbattleoption then
						tmps = "*" .. tmp[i]
					else
						tmps = " " .. tmp[i]
					end
					love.graphics.print(tmps, x, 515)
					i=i+1
				end
				
				

			dbg=dbg .. n .." - " .. selectedenemy
		end
	elseif gamemode == "intro" then
		
		n=table.maxn(intro)
		if introi<n+1 then
			love.graphics.draw(intro[introi],0,0)
			if introi <23 then
				introi=introi+1
			end
		else
			gamemode="gameplay"
		end
	
		
	elseif gamemode == "menu" then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(bgimg, 0, 0)
		love.graphics.setFont(twotrees48)
		love.graphics.printf(programname, 0, 40, gw, 'center')
		love.graphics.setFont(twotrees36)
		i = 1
		hx = 400
		while i < mainmenumax+1 do
			if i == mainmenuindex then
				love.graphics.setColor(255,255,0,255)
			else
				love.graphics.setColor(255,255,255,255)
			end
			love.graphics.printf(mainmenuentries[i], 0, hx, gw, 'center')
			hx=hx+20
			i=i+1
		end
	elseif gamemode=="loadscreen" then
		if savedgames~=nil then
			n=table.maxn(savedgames)
			i=1
			while i < n+1 do
				love.graphics.printf(savedgames[i],0,gx,gw,'center')
				i=i+1
			end
		end
	elseif gamemode == "pausemenu" then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(bgimg, 0, 0)
		love.graphics.setFont(twotrees48)
		love.graphics.printf("Paused", 0, 40, gw, 'center')
		love.graphics.setFont(twotrees36)
		i = 1
		hx = 400
		while i < pausemenumax+1 do
			if i == pausemenuindex then
				love.graphics.setColor(255,255,0,255)
			else
				love.graphics.setColor(255,255,255,255)
			end
			love.graphics.printf(pausemenuentries[i], 0, hx, gw, 'center')
			hx=hx+20
			i=i+1
		end
	elseif gamemode == "videomenu" then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(bgimg, 0, 0)
		love.graphics.setFont(twotrees48)
		love.graphics.printf("Video Options", 0, 40, gw, 'center')
		love.graphics.setFont(twotrees36)
		i = 1
		hx = 400
		while i < videomenumax+1 do
			if i == videomenuindex then
				love.graphics.setColor(255,255,0,255)
			else
				love.graphics.setColor(255,255,255,255)
			end
			love.graphics.printf(videomenuentries[i], 0, hx, gw, 'center')
			hx=hx+20
			i=i+1
		end
	elseif gamemode == "gameoptions" then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(bgimg, 0, 0)
		love.graphics.setFont(twotrees48)
		love.graphics.printf("Paused", 0, 40, gw, 'center')
		love.graphics.setFont(twotrees36)
		i = 1
		hx = 400
		while i < optionsmenumax+1 do
			if i == optionsmenuindex then
				love.graphics.setColor(255,255,0,255)
			else
				love.graphics.setColor(255,255,255,255)
			end
			love.graphics.printf(optionsmenuentries[i], 0, hx, gw, 'center')
			hx=hx+20
			i=i+1
		end
		if showcontrols==true then
			love.graphics.draw(controlsimg, 0, 0)
		end
	end
	
	if debugmode==true then
		love.graphics.setFont(verdana8)
		love.graphics.print("FPS: "..tostring(love.timer.getFPS( )) .. " mmi: " .. mainmenuindex .. " omi: " ..optionsmenuindex .. " gm: " .. gamemode .. " prox: " .. protagX .. " proy: " .. protagY .. " dbg: " .. dbg, 10, 10)
		love.graphics.setFont(verdana18)
	end

	
end
--linecount