movespeed = 4
okaytomove=false
function movementcontrols()

	if love.keyboard.isDown("up") and calcy-movespeed>=(0) or love.keyboard.isDown( "w" ) and calcy-movespeed>=(0)   then
		pixelupl = {collisionmap:getPixel(calcx, (calcy-movespeed+30))}
		pixelupr = {collisionmap:getPixel(calcx+protagWidth, (calcy-movespeed+30))}
		okaytoanim=true
	else
		pixelupl = {0,0,0}
		pixelupr = {0,0,0}
	end
	if love.keyboard.isDown("down") and (calcy+protagHeight)+movespeed<(map:getHeight()) or	love.keyboard.isDown( "s" ) and (calcy+protagHeight)+movespeed<(map:getHeight()) then
		pixeldownl = {collisionmap:getPixel(calcx, (calcy+movespeed)+protagHeight)}
		pixeldownr = {collisionmap:getPixel(calcx+protagWidth, (calcy+movespeed)+protagHeight)}
		okaytoanim=true
	else
		pixeldownl = {0,0,0}
		pixeldownr = {0,0,0}
	end
	if love.keyboard.isDown("left") and calcx-movespeed>=(0)  or	love.keyboard.isDown( "a" ) and calcx-movespeed>=(0)  then	
		pixelleftt = {collisionmap:getPixel((calcx-movespeed), calcy+30)}
		pixelleftb = {collisionmap:getPixel((calcx-movespeed), calcy+protagHeight)}
		okaytoanim=true
	else
		pixelleftt = {0,0,0}
		pixelleftb = {0,0,0}
	end
	if love.keyboard.isDown("right") and (calcx+protagWidth)+movespeed<(map:getWidth()) or love.keyboard.isDown( "d" ) and (calcx+protagWidth)+movespeed<(map:getWidth()) then	
		pixelrightt = {collisionmap:getPixel((calcx+movespeed)+protagWidth,  calcy+30)}
		pixelrightb = {collisionmap:getPixel((calcx+movespeed)+protagWidth,  calcy+protagHeight)}
		okaytoanim=true
	else
		pixelrightt = {0,0,0}
		pixelrightb = {0,0,0}
	end


	if love.keyboard.isDown( "up" ) or love.keyboard.isDown( "w" ) then
	
		if pixelupl[1] ==150 and pixelupr[1] ==150 then
			loadmap(warp0, warp0xy[1], warp0xy[2], warp0xy[3], warp0xy[4])
		elseif pixelupl[1] ==151 and pixelupr[1] ==151 then
			loadmap(warp1, warp1xy[1], warp1xy[2], warp1xy[3], warp1xy[4])
		elseif pixelupl[1] ==152 and pixelupr[1] ==152 then
			loadmap(warp2, warp2xy[1], warp2xy[2], warp2xy[3], warp2xy[4])
		elseif pixelupl[1] ==153 and pixelupr[1] ==153 then
			loadmap(warp3, warp3xy[1], warp3xy[2], warp3xy[3], warp3xy[4])
		elseif pixelupl[1] ==154 and pixelupr[1] ==154 then
			loadmap(warp4, warp4xy[1], warp4xy[2], warp4xy[3], warp4xy[4])
		elseif pixelupl[1] ==0 or  pixelupr[1] ==0 then
			okaytomove=false
		else
			if collrect ~=nil and table.maxn(collrect)>0 then
				n= table.maxn(collrect)
				i=1
				while i < n+1 do
					if calcy-movespeed < collrect[i][4]-20 then
						if calcy > collrect[i][2]+0 and calcx+protagWidth > collrect[i][1]+0 and calcx < collrect[i][3]-5 then
							okaytomove=false
							interactable=collrect[i][5] ..",".. i
							collnum=i
							break
						else
							okaytomove=true
							interactable=nil
						end
					else
						okaytomove=true
					end
					i=i+1
				end
			else
				okaytomove=true
				interactable=nil
			end
		end

		if okaytomove==true then
			if protagY < 200 then	
				cameraoffsety=cameraoffsety+movespeed
			else
				protagY=protagY-movespeed
			end
		end
		if direction~="north" then
			protag:seek(1)
		elseif protag:getCurrentFrame() ==3 then
			protag:seek(1)
		end
		direction="north"
		
	elseif love.keyboard.isDown( "down" )  or love.keyboard.isDown( "s" ) then
		if pixeldownl[1] ==150 and pixeldownr[1] ==150 then
			loadmap(warp0, warp0xy[1], warp0xy[2], warp0xy[3], warp0xy[4])
		elseif pixeldownl[1] ==151 and pixeldownr[1] ==151 then
			loadmap(warp1, warp1xy[1], warp1xy[2], warp1xy[3], warp1xy[4])
		elseif pixeldownl[1] ==152 and pixeldownr[1] ==152 then
			loadmap(warp2, warp2xy[1], warp2xy[2], warp2xy[3], warp2xy[4])
		elseif pixeldownl[1] ==153 and pixeldownr[1] ==153 then
			loadmap(warp3, warp3xy[1], warp3xy[2], warp3xy[3], warp3xy[4])
		elseif pixeldownl[1] ==154 and pixeldownr[1] ==154 then
			loadmap(warp4, warp4xy[1], warp4xy[2], warp4xy[3], warp4xy[4])
		elseif pixeldownl[1] ==0 or  pixeldownr[1] ==0 then
			okaytomove=false
		else
			if collrect ~=nil and table.maxn(collrect)>0 then
				n= table.maxn(collrect)
				i=1
				while i < n+1 do
					if calcy+movespeed > collrect[i][2]+0 then
						if calcy < (collrect[i][4]-20) and (calcx+protagWidth) > (collrect[i][1]+0) and calcx < (collrect[i][3]-5) then
							okaytomove=false
							interactable=collrect[i][5] ..",".. i
							collnum=i
							break
						else
							okaytomove=true
							interactable=nil
						end
					else
						okaytomove=true
						interactable=nil
					end
					i=i+1
				end
			else
				okaytomove=true
				interactable=nil
			end
		end
		
		if okaytomove==true then
			if protagY > (gh - 200) then	
				cameraoffsety=cameraoffsety-movespeed
			else
			protagY=protagY+movespeed
			end
		end
		if direction~="south" then
			protag:seek(7)
		elseif protag:getCurrentFrame() ==9 then
			protag:seek(7)
		end
		direction="south"
	elseif love.keyboard.isDown( "left" ) or love.keyboard.isDown( "a" )  then
		if pixelleftt[1] ==150 and pixelleftb[1] ==150 then
			loadmap(warp0, warp0xy[1], warp0xy[2], warp0xy[3], warp0xy[4])
		elseif pixelleftt[1] ==151 and pixelleftb[1] ==151 then
			loadmap(warp1, warp1xy[1], warp1xy[2], warp1xy[3], warp1xy[4])
		elseif pixelleftt[1] ==152 and pixelleftb[1] ==152 then
			loadmap(warp2, warp2xy[1], warp2xy[2], warp2xy[3], warp2xy[4])
		elseif pixelleftt[1] ==153 and pixelleftb[1] ==153 then
			loadmap(warp3, warp3xy[1], warp3xy[2], warp3xy[3], warp3xy[4])
		elseif pixelleftt[1] ==154 and pixelleftb[1] ==154 then
			loadmap(warp4, warp4xy[1], warp4xy[2], warp4xy[3], warp4xy[4])
		elseif pixelleftt[1] ==0 or pixelleftb[1] ==0 then
			okaytomove=false		
		else
			if collrect ~=nil and table.maxn(collrect)>0 then
				n= table.maxn(collrect)
				i=1
				while i < n+1 do
					if calcx-movespeed < collrect[i][3]-5 then
						if calcy > (collrect[i][2]+0) and calcy < (collrect[i][4]-20) and (calcx) > (collrect[i][1]+0) then
							okaytomove=false
							interactable=collrect[i][5] ..",".. i
							collnum=i
							break
						else
							okaytomove=true
							interactable=nil
						end
					else
						okaytomove=true
						interactable=nil
					end
					i=i+1
				end
			else
				okaytomove=true
				interactable=nil
			end
		end
		if okaytomove==true then	
			if protagX < (200) then	
				cameraoffsetx=cameraoffsetx+movespeed
			else
			protagX=protagX-movespeed
			end
		end
		if direction~="west" then
			protag:seek(10)
		elseif protag:getCurrentFrame() ==12 then
			protag:seek(10)
		end
		direction="west"
	elseif love.keyboard.isDown( "right" )  or love.keyboard.isDown( "d" ) then
		if pixelrightt[1] ==150 and pixelrightb[1] ==150 then
			loadmap(warp0, warp0xy[1], warp0xy[2], warp0xy[3], warp0xy[4])
		elseif pixelrightt[1] ==151 and pixelrightb[1] ==151 then
			loadmap(warp1, warp1xy[1], warp1xy[2], warp1xy[3], warp1xy[4])
		elseif pixelrightt[1] ==152 and pixelrightb[1] ==152 then
			loadmap(warp2, warp2xy[1], warp2xy[2], warp2xy[3], warp2xy[4])
		elseif pixelrightt[1] ==153 and pixelrightb[1] ==153 then
			loadmap(warp3, warp3xy[1], warp3xy[2], warp3xy[3], warp3xy[4])
		elseif pixelrightt[1] ==154 and pixelrightb[1] ==154 then
			loadmap(warp4, warp4xy[1], warp4xy[2], warp4xy[3], warp4xy[4])
		elseif pixelrightt[1] ==0 or pixelrightb[1] ==0 then
			okaytomove=false
		else
			if collrect ~=nil and table.maxn(collrect)>0 then
				n= table.maxn(collrect)
				i=1
				while i < n+1 do
					if (calcx+movespeed) > collrect[i][1]-protagWidth then
						if calcy > (collrect[i][2]+0) and calcy < (collrect[i][4]-20) and calcx < (collrect[i][3]-5) then
							okaytomove=false
							interactable=collrect[i][5] ..",".. i
							collnum=i
							break
						else
							okaytomove=true
							interactable=nil
						end
					else
						okaytomove=true
						interactable=nil
					end
					i=i+1
				end
			else
				okaytomove=true
				interactable=nil
			end
		end
		if okaytomove==true then
			if protagX > (gw - 200) then	
				cameraoffsetx=cameraoffsetx-movespeed
			else
				protagX=protagX+movespeed
			end
		end
		if direction~="east" then
			protag:seek(4)
		elseif protag:getCurrentFrame() ==6 then
			protag:seek(4)
		end
		direction="east"
		
	end
calcx=protagX-cameraoffsetx 
calcy=protagY - cameraoffsety
end
