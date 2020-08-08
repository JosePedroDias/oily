# sticky situation 🛢

## TL;DR

A multiplayer game.
Players are placed underground and have the objective of digging dirt so that oil reaches their tower(s).
First player to capture 300 oil gallons win.

Each player can move either digging or placing dirt. There's a maximum amount of holes one can perform so
use your potential carefully.
Players can't touch oil so don't get surrounded by it ;)

This game intended to be a submission to the [multiplayer game jam](https://itch.io/jam/multiplayer-jam) 🤞.

_Controls_:

- arrows move the player
- space bar toggles between placing and digging dirt (having reached 0 holes the mode switches for you as well)

## BUGS 🐞

- game state seems borked when a NEW game occurs (server issue?)

## TODO 🧑‍🍳

- draw capturing towers
- draw pretty players
- generate noise rocks procedurally
- have a couple more base maps (placement of sinks and players)
- title screen
- detect game over
- support multiple games

## Credits 😅

- game code and concept by José Pedro Dias
- additional game design and beta testing by António José da Silva.

## Resources 📖

This game was coded in [lua](http://www.lua.org/) with the awesome [love2d](https://love2d.org/) game framework.  
Network code based on [enet](http://enet.bespin.org/) / [enet lua bindings](https://leafo.net/lua-enet/).
