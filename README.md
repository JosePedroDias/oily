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

- procedural map
  - confirm oil starts not in/surrounded by cave (not REQUIRED)
  - more than one tower per player? (may be confusing)
- eyecandy
  - use textures instead of solid colors for materials (https://love2d.org/wiki/love.graphics.polygon + texture vs surface stencil)
  - add a sky texture
  - zoom camera according to action
- network
  - remove space btw cmd and args in netcode
  - support multiple games in the same server?
    - op1: above 2 players kicks client
    - op2: above 2 players places client in channel 2, to play next
      - will other players spectate or just wait?
    - accept players above 2?
- playability
  - eventual support for more than 2 players? (server-side already works I guess)
- title screen
- detect game overs
  - player between oil
  - no more holes (player spent theirs and oil filled map holes)

## Credits 😅

- game code and concept by José Pedro Dias
- additional game design and beta testing by António José da Silva.

## Resources 📖

This game was coded in [lua](http://www.lua.org/) with the awesome [love2d](https://love2d.org/) game framework.  
Network code based on [enet](http://enet.bespin.org/) / [enet lua bindings](https://leafo.net/lua-enet/).
