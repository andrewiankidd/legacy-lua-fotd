local Frames = require("love2d4me").frames
local layout = Frames.get("4dir_3frame")

local MOVE_SPEED = 4
local CAMERA_SCROLL_MARGIN = 200
local SPRITE_TOP_OFFSET = 30
local INTERACT_RANGE = 30

local function check_edge(state, x1, y1, x2, y2)
    local p1 = state.collision:check(x1, y1)
    local p2 = state.collision:check(x2, y2)
    if p1 == "warp" and p2 == "warp" then
        local warp = state.collision:get_warp(x1, y1)
        if warp then loadmap(warp.target, warp.spawn) end
        return "warp"
    end
    if p1 == "solid" or p2 == "solid" then return "solid" end
    return "walk"
end

local function check_collrects(state, dir)
    if not state.collrect or table.maxn(state.collrect) == 0 then return true end
    local nx = state.calc_x + (dir == "left" and -MOVE_SPEED or dir == "right" and MOVE_SPEED or 0)
    local ny = state.calc_y + (dir == "up" and -MOVE_SPEED or dir == "down" and MOVE_SPEED or 0)
    for i = 1, table.maxn(state.collrect) do
        if state.collrect[i] then
            local rx1, ry1, rx2, ry2 = state.collrect[i][1], state.collrect[i][2], state.collrect[i][3], state.collrect[i][4]
            if nx + state.w > rx1 and nx < rx2 - 5 and ny + state.h > ry1 and ny < ry2 then
                return false
            end
        end
    end
    return true
end

local function find_nearby_interactable(state)
    if not state.collrect or table.maxn(state.collrect) == 0 then return nil end
    local px = state.calc_x + state.w / 2
    local py = state.calc_y + state.h / 2
    for i = 1, table.maxn(state.collrect) do
        if state.collrect[i] then
            local rx1, ry1, rx2, ry2, rtype = state.collrect[i][1], state.collrect[i][2], state.collrect[i][3], state.collrect[i][4], state.collrect[i][5]
            local cx = (rx1 + rx2) / 2
            local cy = (ry1 + ry2) / 2
            local dx = px - cx
            local dy = py - cy
            local half_w = (rx2 - rx1) / 2 + INTERACT_RANGE
            local half_h = (ry2 - ry1) / 2 + INTERACT_RANGE
            if math.abs(dx) < half_w and math.abs(dy) < half_h then
                return rtype .. "," .. i
            end
        end
    end
    return nil
end

function movementcontrols(dt, state)
    local moved = false

    if Input.held("move_up") and state.calc_y - MOVE_SPEED >= 0 then
        local perm = check_edge(state, state.calc_x, state.calc_y - MOVE_SPEED + SPRITE_TOP_OFFSET, state.calc_x + state.w, state.calc_y - MOVE_SPEED + SPRITE_TOP_OFFSET)
        if perm == "walk" and check_collrects(state, "up") then
            moved = true
            if state.y < CAMERA_SCROLL_MARGIN then
                state.camera_y = state.camera_y + MOVE_SPEED
            else
                state.y = state.y - MOVE_SPEED
            end
        end
        if state.direction ~= "north" then state.anim:seek(layout.face.north)
        elseif state.anim:getCurrentFrame() == 3 then state.anim:seek(layout.face.north) end
        state.direction = "north"

    elseif Input.held("move_down") and (state.calc_y + state.h) + MOVE_SPEED < (state.map:getHeight()) then
        local perm = check_edge(state, state.calc_x, (state.calc_y + MOVE_SPEED) + state.h, state.calc_x + state.w, (state.calc_y + MOVE_SPEED) + state.h)
        if perm == "walk" and check_collrects(state, "down") then
            moved = true
            if state.y > (state.gh - CAMERA_SCROLL_MARGIN) then
                state.camera_y = state.camera_y - MOVE_SPEED
            else
                state.y = state.y + MOVE_SPEED
            end
        end
        if state.direction ~= "south" then state.anim:seek(layout.face.south)
        elseif state.anim:getCurrentFrame() == 9 then state.anim:seek(layout.face.south) end
        state.direction = "south"

    elseif Input.held("move_left") and state.calc_x - MOVE_SPEED >= 0 then
        local perm = check_edge(state, state.calc_x - MOVE_SPEED, state.calc_y + SPRITE_TOP_OFFSET, state.calc_x - MOVE_SPEED, state.calc_y + state.h)
        if perm == "walk" and check_collrects(state, "left") then
            moved = true
            if state.x < CAMERA_SCROLL_MARGIN then
                state.camera_x = state.camera_x + MOVE_SPEED
            else
                state.x = state.x - MOVE_SPEED
            end
        end
        if state.direction ~= "west" then state.anim:seek(layout.face.west)
        elseif state.anim:getCurrentFrame() == 12 then state.anim:seek(layout.face.west) end
        state.direction = "west"

    elseif Input.held("move_right") and (state.calc_x + state.w) + MOVE_SPEED < (state.map:getWidth()) then
        local perm = check_edge(state, (state.calc_x + MOVE_SPEED) + state.w, state.calc_y + SPRITE_TOP_OFFSET, (state.calc_x + MOVE_SPEED) + state.w, state.calc_y + state.h)
        if perm == "walk" and check_collrects(state, "right") then
            moved = true
            if state.x > (state.gw - CAMERA_SCROLL_MARGIN) then
                state.camera_x = state.camera_x - MOVE_SPEED
            else
                state.x = state.x + MOVE_SPEED
            end
        end
        if state.direction ~= "east" then state.anim:seek(layout.face.east)
        elseif state.anim:getCurrentFrame() == 6 then state.anim:seek(layout.face.east) end
        state.direction = "east"
    end

    state.calc_x = state.x - state.camera_x
    state.calc_y = state.y - state.camera_y

    local interactable = find_nearby_interactable(state)
    return moved, interactable
end
