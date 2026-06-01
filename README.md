# legacy-lua-fotd
##### _Fear of the Dark_

![logo](assets/logo.png)

## About
**Fear of the Dark** is a retro top-down RPG built with Lua and [LOVE2D](https://love2d.org), originally written around 2011. Explore maps, fight mobs, collect items, and talk to NPCs. A spiritual successor to [cellgame](https://github.com/andrewiankidd/legacy-vb-cellgame).

## Features
- Dynamic NPC system — add characters with a folder: script, portrait, sprite
- Map system with collision maps, warps, overlays, and entity placement
- Combat encounters with stats-driven battles
- Item collection and quest objectives (hasitem, goto, talkto)
- Camera panning for maps of any size
- Web build via love.js (WASM)

### Links
<p align="center">
    <a href="https://andrewiankidd.github.io/legacy-lua-fotd/">
        <img src="https://img.shields.io/badge/%F0%9F%8E%AE%20FotD-darkred.svg" height="50" target="_blank" />
    </a>
    <br>
    <strong>Play:</strong>
    <br>
    <a href="https://andrewiankidd.github.io/legacy-lua-fotd/Web/index.html">
        <img src="https://img.shields.io/badge/%f0%9f%8c%90%20Browser-darkred.svg" />
    </a>
    <a href="https://github.com/andrewiankidd/legacy-lua-fotd/releases/download/latest-main/FotD-love.zip">
        <img src="https://img.shields.io/badge/.love%20File-darkred.svg" />
    </a>
    <br>
    <strong>Source Code:</strong>
    <br>
    <a href="https://github.com/andrewiankidd/legacy-lua-fotd">
        <img src="https://img.shields.io/badge/GitHub-darkred.svg?logo=gitHub" />
    </a>
    <br>
    <a href="https://github.com/andrewiankidd/legacy-lua-fotd/actions/workflows/publish.yml">
        <img src="https://github.com/andrewiankidd/legacy-lua-fotd/actions/workflows/publish.yml/badge.svg" />
    </a>
</p>

## Video

Click to play

[![screenshot](assets/screenshot.png)](https://youtu.be/42uv4JNxzfo)

## Running locally

    npm run setup      # install npm deps + download LOVE 11.5
    npm start          # launch the game

### Web build

    npm run build      # pack src/ into .love, compile to Web/ via love.js
    npm run serve      # serve Web/ at http://localhost:8080

## Documentation

See the [docs](docs/index.md) for game systems and file structure.

## License

MIT License. See `LICENSE` file for details.
