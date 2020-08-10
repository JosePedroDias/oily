# Oily 🛢

## TL;DR

A multiplayer game over network. Can be played alone as well.
Players are placed underground and have the objective of digging dirt so that oil reaches their tower(s).
First player to capture 100 oil gallons win.

Each player can move either digging or placing dirt.
There's a maximum amount of holes one can perform so use your potential carefully and fetch more from caves in the map.
Players can't move past oil so don't get yourself surrounded by it!

This game is submission to the [multiplayer game jam](https://itch.io/jam/multiplayer-jam).

_Controls_ ⌨️

- `arrows` move the player
- `space bar` toggles between placing and digging dirt (having reached 0 holes the mode switches for you as well)
- `R` starts a new map (if you get stuck for instance). Please don't use it during a game 🙏

## TODO 🧑‍🍳

- title screen 🇴 🇮 🇱 🇾 (ongoing...)
- instructions 📃
- eyecandy 🌈
  - fullscreen toggle
  - hint exact placement of extraction (vertical line in tower)
  - add a sky texture
  - use textures instead of solid colors for materials (https://love2d.org/wiki/love.graphics.polygon + texture vs surface stencil)
  - close in camera according to action context
- network 🕸
  - for now 2 slots in a single channel/session. additional people wait for turn to enter
  - remove space btw cmd and args in netcode
- game overs detection 💀
  - player between oil
  - no more holes (player spent theirs and oil filled map holes)
- procedural map 🗺
  - confirm oil starts not in/surrounded by cave (not REQUIRED)
  - more than one tower per player? (may be confusing)

## Game round management

Playing always connects and interacts with the server. If no other player is around, you play solo. As soon as another player joins, a 2 player game starts - while you both are there you can play several games.

If you get in when a 2 player game is happening, you will be queued to enter as soon as another players leaves.
(I haven't thoroughly tested the retry code so in the unlikely event of you not getting in in 2-5 min restart the game).

## Credits 😅

- game code, concept and laughable artwork by José Pedro Dias;
- additional game design and beta testing by António José da Silva.

## Resources 📖

This game was coded in [lua](http://www.lua.org/) with the awesome [love2d](https://love2d.org/) game framework.  
Network code based on [enet](http://enet.bespin.org/) / [enet lua bindings](https://leafo.net/lua-enet/).
