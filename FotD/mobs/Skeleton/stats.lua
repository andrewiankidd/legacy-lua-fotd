mobname="Skeleton"
mobhp="2"
mobatk="1"
--don't touch below this line
src = love.graphics.newImage("mobs/"..mobname.."/sprite.png")
battlesprites[mobname] = newAnimation(src, 36, 48, 0.1, 0)