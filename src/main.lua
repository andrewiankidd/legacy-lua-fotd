local Love2D4Me = require("love2d4me")
Input = Love2D4Me.input
local GameState = Love2D4Me.gamestate
local Player = Love2D4Me.player
local MapLoader = Love2D4Me.maploader
local Notification = Love2D4Me.notification
local Dialog = Love2D4Me.dialog
local NPC = Love2D4Me.npc
local DayNight = Love2D4Me.daynight
local Inventory = Love2D4Me.inventory
local QuestsModule = Love2D4Me.quests
local SaveGame = Love2D4Me.savegame
local Battle = Love2D4Me.battle
local RPG = Love2D4Me.rpg
local Fonts = Love2D4Me.fonts
local Collision = Love2D4Me.collision
local Frames = Love2D4Me.frames
local HUD = Love2D4Me.hud
require("game.movement")

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Constants
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local SPRITE_W, SPRITE_H = 36, 48
local BATTLE_SPRITE_W, BATTLE_SPRITE_H = 75, 72
local ANIM_FRAME_DURATION = 0.1
local ANIM_START_FRAME = 0
local ITEM_COLLISION_SIZE = 20
local NPC_COLLISION_OFFSET_Y = 20
local DEFAULT_SPAWN_X = 200
local DEFAULT_SPAWN_Y = 200

local UI_MSG_BOX_Y = 0.72
local UI_MSG_TEXT_X = 0.03
local UI_MSG_TEXT_Y = 0.83
local UI_MSG_TEXT_W = 0.9
local UI_LIST_TOP = 0.07
local UI_LIST_SPACING = 0.033

local COLOR_WHITE = {1, 1, 1, 1}
local COLOR_BLACK = {0, 0, 0, 1}
local COLOR_DIM = {0.5, 0.5, 0.5, 0.5}

local face_layout = Frames.get("4dir_3frame")


-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Player state (replaces all globals -- passed to movement.lua)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local state = nil

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- File-local state
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local entities = {}
local collrect_to_entity = {}
local collrect_to_item = {}
local itemimg = {}
local itemlist = nil
local obtaineditemids = {}
local mapoverlay = nil
local lightmap = nil
local islightmap = false
local showmsgscreen = false
local msgstring = nil
local cancontinue = false
local rii = 1
local ri = 1
local lastxpgain = 0
local intro = {}
local introi = 1
local savedgames = nil
local playername = "YOU"
local battle_entity_idx = nil
local interactable_str = nil

local function make_anim(sprite_img)
    return newAnimation(sprite_img, SPRITE_W, SPRITE_H, ANIM_FRAME_DURATION, ANIM_START_FRAME)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Gameplay init
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function gameplay_init()
    local cfg = GameState.get_config()
    local protag_data = NPC.load("protag")
    local gw, gh = GameState.get_game_size()

    state = Player.new({
        x = 0, y = 0,
        w = SPRITE_W - 10, h = SPRITE_H - 3,
        anim = make_anim(protag_data.sprite),
        direction = "south",
    })
    state.gw = gw
    state.gh = gh
    state.collrect = {}
    state.map = nil

    HUD.set_controls({
        "Arrows: Move",
        "Enter: Interact",
        "Tab: Inventory",
        "Q: Journal",
        "Esc: Pause",
    })

    RPG.init({
        hp = cfg.rpg and cfg.rpg.hp or 10,
        dmg = cfg.rpg and cfg.rpg.dmg or 1,
        level = cfg.rpg and cfg.rpg.level or 1,
        xp = cfg.rpg and cfg.rpg.xp or 0,
        on_death = function() GameState.set_state("dead") end,
        on_levelup = function() GameState.set_state("levelup") end,
    })

    loadintro()
    loadmap(cfg.starting_map or "Asgarourhouse2")
    newobjective(cfg.starting_quest or "001")

    if state.debug then
        RPG.set("hp", 10000)
        loadmap("route1")
    end
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Map / game functions
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function loadintro()
    intro = {}
    introi = 1
    local idx = 1
    while love.filesystem.getInfo("game/pictures/intro/" .. idx .. ".png") do
        intro[idx] = love.graphics.newImage("game/pictures/intro/" .. idx .. ".png")
        idx = idx + 1
    end
end

function loadmap(mapname, spawn_override)
    state.collrect = {}
    collrect_to_entity = {}
    collrect_to_item = {}
    entities = {}
    itemimg = {}

    local loaded = MapLoader.load(mapname)
    state.map = loaded.background
    mapoverlay = loaded.overlay
    lightmap = loaded.lights
    islightmap = loaded.has_lights

    local cfg = loaded.config

    local WARP_BASE_COLOR = 150
    local warp_lookup = {}
    for i, w in ipairs(cfg.warps or {}) do
        local spawn = w.spawn
        if type(spawn) == "table" and spawn[1] then
            spawn = { x = spawn[1], y = spawn[2], cam_x = spawn[3], cam_y = spawn[4] }
        end
        warp_lookup[WARP_BASE_COLOR + i - 1] = { target = w.target, spawn = spawn }
    end

    if loaded.collision then
        state.collision = Collision.new(loaded.collision, {
            [0] = "solid",
            [255] = "walk",
        }, warp_lookup)
    end

    for i, entry in ipairs(cfg.entities or {}) do
        local entity = NPC.create_entity(entry, make_anim)
        if entity.anim and entity.behavior == "static" then
            entity.anim:seek(face_layout.idle.south)
        end
        entities[i] = entity

        if entity.interaction == "button" then
            local nn = #state.collrect + 1
            state.collrect[nn] = { entry.x, entry.y - NPC_COLLISION_OFFSET_Y, entry.x + SPRITE_W, entry.y + SPRITE_H, "entity" }
            collrect_to_entity[nn] = i
        end
    end

    local items_cfg = cfg.items or {}
    itemlist = {}
    for i, item in ipairs(items_cfg) do
        itemlist[i] = {
            id = item.id,
            x = item.x, y = item.y,
            uid = item.uid or i,
            condition = item.condition,
        }
    end

    local spawn = spawn_override or cfg.spawn or {}
    if type(spawn) ~= "table" or spawn[1] then
        spawn = { x = DEFAULT_SPAWN_X, y = DEFAULT_SPAWN_Y, cam_x = 0, cam_y = 0 }
    end
    state.x = tonumber(spawn.x) or DEFAULT_SPAWN_X
    state.y = tonumber(spawn.y) or DEFAULT_SPAWN_Y
    state.camera_x = tonumber(spawn.cam_x) or 0
    state.camera_y = tonumber(spawn.cam_y) or 0
    Player.update_calc(state)

    for i, item in ipairs(itemlist) do
        if not obtaineditemids[item.uid] then
            if not itemimg[item.id] then
                itemimg[item.id] = love.graphics.newImage("game/items/" .. item.id .. "/sprite.png")
            end
            local nn = #state.collrect + 1
            state.collrect[nn] = { item.x, item.y, item.x + ITEM_COLLISION_SIZE, item.y + ITEM_COLLISION_SIZE, "item" }
            collrect_to_item[nn] = i
        end
    end
end

function interact(obj)
    if obj == nil then return end
    local dirtoface = face_layout.face_player[state.direction] or face_layout.face_player.south
    local ixy = stringsplit(obj, ",")
    local objtype = ixy[1]
    local collrect_idx = tonumber(ixy[2])

    if objtype == "entity" then
        local entity_idx = collrect_to_entity[collrect_idx]
        local entity = entities[entity_idx]
        if entity and entity.anim then entity.anim:seek(dirtoface) end
        if entity then chat(entity.character.name) end
    elseif objtype == "item" then
        local item_idx = collrect_to_item[collrect_idx]
        local item = item_idx and itemlist[item_idx]
        if item then
            Inventory.add(item.id)
            QuestsModule.check("hasitem", item.id)
            obtaineditemids[item.uid] = true
            state.collrect[collrect_idx] = nil
            interactable_str = nil
        end
    end
end

function start_battle(entity_idx)
    local JSON = Love2D4Me.json
    local entity = entities[entity_idx]
    if not entity then return end
    local mob_data = JSON.load(entity.character.dir .. "config.json") or {}

    local mob_battle_anim = nil
    if entity.character.sprite then
        mob_battle_anim = make_anim(entity.character.sprite)
        mob_battle_anim:seek(face_layout.face.west)
    end

    local enemy_count = math.random(1, 3)
    local enemy_list = {}
    for i = 1, enemy_count do
        table.insert(enemy_list, {
            name = mob_data.name or entity.character.name,
            hp = mob_data.hp or 2,
            atk = mob_data.attack or 1,
            sprite = mob_battle_anim,
        })
    end

    battle_entity_idx = entity_idx
    lastxpgain = 0
    local protag_data = NPC.get("protag")
    local battle_anim = newAnimation(protag_data.battle_sprite, BATTLE_SPRITE_W, BATTLE_SPRITE_H, ANIM_FRAME_DURATION, ANIM_START_FRAME)
    Battle.start({
        player = { hp = RPG.get("hp"), dmg = RPG.get("dmg"), sprite = battle_anim },
        enemies = enemy_list,
        on_win = function(xp)
            entities[battle_entity_idx].alive = false
            lastxpgain = xp
            ri = 1; rii = 1; cancontinue = false
            GameState.set_state("rewardscreen")
        end,
        on_lose = function() GameState.set_state("dead") end,
        on_run = function()
            NPC.stun(entities[battle_entity_idx], 2)
            GameState.set_state("gameplay")
        end,
    })
    GameState.set_state("battle")
end

function chat(name)
    local JSON = Love2D4Me.json
    local npc_data = NPC.load(name)
    local lines = {"..."}

    local dialog_data = JSON.load(npc_data.dir .. "dialog.json")
    if dialog_data and dialog_data.dialog then
        for _, entry in ipairs(dialog_data.dialog) do
            if entry.condition then
                local ctype, cval = entry.condition:match("([^:]+):(.+)")
                if ctype == "objective" and QuestsModule.get_current_id() == cval then
                    lines = entry.lines or lines
                    if entry.actions then
                        for _, action in ipairs(entry.actions) do
                            local atype, aval = action:match("([^:]+):(.+)")
                            if atype == "removeitem" then Inventory.remove(aval) end
                        end
                    end
                    break
                end
            elseif lines[1] == "..." then
                lines = entry.lines or lines
            end
        end
    end

    Dialog.open(name, npc_data.portrait, lines)
    QuestsModule.check("talkto", name)
end

function newobjective(ToLoad)
    QuestsModule.add(ToLoad)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Custom game states
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function register_states()
    GameState.register("intro", {
        update = function(dt)
            if Input.pressed("confirm") then introi = introi + 1 end
        end,
        draw = function()
            local count = table.maxn(intro)
            if introi < count + 1 then
                draw_fullscreen(intro[introi])
                if introi < 23 then introi = introi + 1 end
            else
                GameState.set_state("gameplay")
            end
        end,
    })

    GameState.register("battle", {
        update = function(dt) Battle.update(dt) end,
        draw = function() Battle.draw() end,
        keypressed = function(key) Battle.keypressed(key) end,
    })

    GameState.register("rewardscreen", {
        update = function(dt)
            if rii > 200 then
                if lastxpgain - ri >= 0 then
                    lastxpgain = lastxpgain - 1
                    RPG.gain_xp(1)
                    rii = 1
                else
                    cancontinue = true
                end
            else
                rii = rii + 40
            end
        end,
        draw = function()
            local sw, sh = love.graphics.getDimensions()
            local bg = get_image("game/pictures/battle/rbg.png")
            if bg then draw_fullscreen(bg) end
            local portrait = NPC.get("protag") and NPC.get("protag").portrait
            if portrait then love.graphics.draw(portrait, sw * 0.16, sh * 0.17) end
            love.graphics.setFont(Fonts.get("twotrees", 28))
            love.graphics.printf("XP Gain:\r\n" .. (lastxpgain or 0), sw * 0.5, sh * 0.07, sw * 0.5, 'center')
            if lastxpgain and lastxpgain > 0 and rii < 300 then
                love.graphics.printf("1", sw * 0.25, sh * 0.08 + rii, sw, 'center')
            else
                love.graphics.printf("Press " .. Input.get_key_name("confirm") .. " to Continue", 0, sh * 0.92, sw, 'center')
            end
            love.graphics.printf("Total XP: " .. RPG.get("xp"), sw * 0.25, sh * 0.5, sw, 'center')
        end,
        keypressed = function(key)
            if Input.pressed("confirm") and cancontinue then
                ri = 1; rii = 1; cancontinue = false
                GameState.set_state("gameplay")
            end
        end,
    })

    GameState.register("dead", {
        draw = function()
            local sw, sh = love.graphics.getDimensions()
            local bg = get_image("game/pictures/battle/death.png")
            if bg then draw_fullscreen(bg) end
            love.graphics.setColor(unpack(COLOR_DIM))
            love.graphics.setFont(Fonts.get("twotrees", 48))
            love.graphics.printf(playername, 0, sh * 0.33, sw, 'center')
            love.graphics.setColor(unpack(COLOR_WHITE))
        end,
    })

    GameState.register("levelup", {
        draw = function()
            local sw, sh = love.graphics.getDimensions()
            local bg = get_image("game/pictures/battle/levelup.png")
            if bg then draw_fullscreen(bg) end
            love.graphics.setFont(Fonts.get("twotrees", 48))
            love.graphics.print("HP:" .. RPG.get("hp"), sw * 0.02, sh * 0.08)
            love.graphics.print("LVL:" .. RPG.get("level"), sw * 0.02, sh * 0.2)
        end,
        keypressed = function(key)
            if Input.pressed("confirm") then GameState.set_state("gameplay") end
        end,
    })

    GameState.register("loadscreen", {
        update = function(dt)
            if savedgames == nil then
                savedgames = SaveGame.list_slots()
                if not savedgames then savedgames = {} end
                table.insert(savedgames, "Return")
            end
        end,
        draw = function()
            if savedgames then
                for i, s in ipairs(savedgames) do
                    local sw, sh = love.graphics.getDimensions()
                    love.graphics.printf(s, 0, sh * UI_LIST_TOP + i * (sh * UI_LIST_SPACING), sw, 'center')
                end
            end
        end,
    })
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Gameplay loop
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local function gameplay_draw()
    love.graphics.setFont(Fonts.get("twotrees", 28))
    love.graphics.draw(state.map, state.camera_x, state.camera_y)

    for i, entity in ipairs(entities) do
        NPC.draw_entity(entity, state.camera_x, state.camera_y)
        if entity.alive and entity.interaction == "collision" and not (entity.stun_timer and entity.stun_timer > 0) then
            if NPC.check_collision(entity, state.calc_x, state.calc_y, state.w, state.h) then
                start_battle(i)
            end
        end
    end

    for _, item in ipairs(itemlist) do
        if not obtaineditemids[item.uid] then
            local visible = true
            if item.condition then
                local _, cval = item.condition:match("([^:]+):(.+)")
                visible = (QuestsModule.get_current_id() == cval)
            end
            if visible and itemimg[item.id] then
                love.graphics.draw(itemimg[item.id], item.x + state.camera_x, item.y + state.camera_y)
            end
        end
    end

    if state.debug and state.collrect and table.maxn(state.collrect) > 0 then
        for i = 1, table.maxn(state.collrect) do
            if state.collrect[i] then
                love.graphics.rectangle("line", state.collrect[i][1] + state.camera_x, state.collrect[i][2] + state.camera_y, state.collrect[i][3] - state.collrect[i][1], state.collrect[i][4] - state.collrect[i][2])
            end
        end
    end

    state.anim:draw(state.x, state.y)
    if interactable_str then
        local prompt = NPC.get("protag") and NPC.get("protag").prompt
        if prompt then love.graphics.draw(prompt, state.x, state.y - ITEM_COLLISION_SIZE) end
    end
    love.graphics.draw(mapoverlay, state.camera_x, state.camera_y)

    DayNight.draw(state.camera_x, state.camera_y, islightmap and lightmap or nil)
    Notification.draw()

    if Dialog.is_active() then
        Dialog.draw()
    elseif showmsgscreen then
        local sw, sh = love.graphics.getDimensions()
        local overlay = get_image("game/pictures/msg/msgoverlay.png")
        if overlay then love.graphics.draw(overlay, 0, sh * UI_MSG_BOX_Y) end
        love.graphics.setColor(unpack(COLOR_BLACK))
        love.graphics.printf(msgstring or "", sw * UI_MSG_TEXT_X, sh * UI_MSG_TEXT_Y, sw * UI_MSG_TEXT_W, 'left')
        love.graphics.setColor(unpack(COLOR_WHITE))
    end

    Inventory.draw()
    QuestsModule.draw()

    if not Dialog.is_active() and not Inventory.is_visible() and not QuestsModule.is_visible() then
        HUD.draw()
    end
end

local function gameplay_update(dt)
    Notification.update(dt)
    DayNight.update(dt)
    Dialog.update(dt)
    if not Dialog.is_active() and not Inventory.is_visible() and not QuestsModule.is_visible() then
        local moved, found_interactable = movementcontrols(dt, state)
        interactable_str = found_interactable
        if moved then state.anim:update(dt) end
        for _, entity in ipairs(entities) do
            NPC.update_entity(entity, dt, state.calc_x, state.calc_y)
        end
    end

    if Dialog.is_active() then
        if Input.pressed("confirm") then Dialog.advance() end
        if Input.pressed("cancel") then Dialog.close() end
    elseif Input.pressed("pause") or Input.pressed("cancel") then
        GameState.set_state("pause")
    elseif Input.pressed("inventory") then Inventory.toggle()
    elseif Input.pressed("quest_log") then QuestsModule.toggle()
    elseif Input.pressed("confirm") then
        if showmsgscreen then showmsgscreen = false
        elseif interactable_str then interact(interactable_str)
        end
    end
end

local function gameplay_keypressed(key)
    if Inventory.keypressed(key) then return end
    if QuestsModule.keypressed(key) then return end
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Boot
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

function love.load()
    register_states()
    GameState.init({
        on_gameplay_init = gameplay_init,
        on_gameplay_start = function() GameState.set_state("intro") end,
        on_gameplay_update = gameplay_update,
        on_gameplay_draw = gameplay_draw,
        on_gameplay_keypressed = gameplay_keypressed,
    })
end

function love.update(dt)
    GameState.update(dt)
end

function love.draw()
    GameState.draw()
end

function love.keypressed(key)
    GameState.keypressed(key)
end

function love.keyreleased(key)
    GameState.keyreleased(key)
end
