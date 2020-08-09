# sticky situation 🛢

## TL;DR

A multiplayer game over network. Can be played alone as well.
Players are placed underground and have the objective of digging dirt so that oil reaches their tower(s).
First player to capture 100 oil gallons win.

Each player can move either digging or placing dirt.
There's a maximum amount of holes one can perform so use your potential carefully and fetch more from caves in the map.
Players can't move past oil so don't get yourself surrounded by it!

This game intended to be a submission to the [multiplayer game jam](https://itch.io/jam/multiplayer-jam) 🤞.

_Controls_:

- arrows move the player
- space bar toggles between placing and digging dirt (having reached 0 holes the mode switches for you as well)
- there's the R button to start a new map (if you get stuck for instance) don't use it during a game please...

## TODO 🧑‍🍳

- sound
  - samples for
    - digging dirt
    - placing dirt
    - no more dirt to dig
    - oil flowing
    - oil being captured
- title screen
- instructions?
- eyecandy
  - add a sky texture
  - use textures instead of solid colors for materials (https://love2d.org/wiki/love.graphics.polygon + texture vs surface stencil)
  - close in camera according to action context
- network
  - for now 2 slots in a single channel/session. additional people wait for turn to enter
  - remove space btw cmd and args in netcode
- detect game overs
  - player between oil
  - no more holes (player spent theirs and oil filled map holes)
- procedural map
  - confirm oil starts not in/surrounded by cave (not REQUIRED)
  - more than one tower per player? (may be confusing)

## Credits 😅

- game code and concept by José Pedro Dias
- additional game design and beta testing by António José da Silva.

## Resources 📖

This game was coded in [lua](http://www.lua.org/) with the awesome [love2d](https://love2d.org/) game framework.  
Network code based on [enet](http://enet.bespin.org/) / [enet lua bindings](https://leafo.net/lua-enet/).
