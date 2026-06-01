// Package the FotD/ game folder into FotD.love (a zip with main.lua at the root).
// Used by `npm run build` so the love.js input is deterministic — passing the
// directory directly makes love.js emit Windows backslash paths that LOVE can't find.
const path = require('path');
const fs = require('fs');
const AdmZip = require('adm-zip');

const root = path.join(__dirname, '..');
const gameDir = path.join(root, 'src');
const out = path.join(root, 'FotD.love');

fs.rmSync(out, { force: true });
const zip = new AdmZip();
zip.addLocalFolder(gameDir);
zip.writeZip(out);
console.log('packed ' + out + ' (' + (fs.statSync(out).size / 1048576).toFixed(2) + ' MB)');
