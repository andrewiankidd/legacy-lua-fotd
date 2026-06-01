# Fear of the Dark

A retro top-down RPG built with Lua and LOVE2D.

## File Structure

All game content lives under `src/` and is loaded dynamically at runtime.

### NPCs
`src/npcs/<name>/`
- `script.lua` — dialog text and item logic
- `picture.png` — portrait displayed during conversation
- `sprite.png` — overworld sprite

### Mobs
`src/mobs/<name>/`
- `sprite.png` — battle sprite
- `stats.lua` — HP, attack damage

### Maps
`src/maps/<name>/`
- `background.png` — base layer
- `collision.png` — walkable area and warp zones (colour-coded)
- `overlay.png` — upper layer (tree tops, roof edges)
- `map.lua` — warp definitions, NPC/mob/item placement

### Items
`src/items/<name>/`
- `image.png` — inventory icon
- `sprite.png` — overworld sprite
- `stats.lua` — item properties

## Objectives

Quest objectives use a simple tag syntax:
- `hasitem:<itemname>` — player must have the item
- `goto:<mapname>` — player must visit the map
- `talkto:<npcname>` — player must talk to the NPC

## Controls

| Key | Action |
|-----|--------|
| Arrow keys | Move |
| Space / Enter | Interact / advance dialog |
| Escape | Menu |

## Getting Started

```bash
npm run setup      # install npm deps + download LOVE 11.5
npm start          # launch the game desktop
```

### Web build

```bash
npm run build      # pack src/ into FotD.love, compile to Web/ via love.js
npm run serve      # serve Web/ at http://localhost:8080
```
