# intro

The game is played through a matrix which is in both client and server.
Each client notifies the server when keyboards presses change.
The server manages it and sends updates based on player states, oil shape and which keys the players are pressing.

# server -> client

(new game)

    ng

(set matrix)

    sm <x>,<y>,<v>

(set matrix rect)

    sr <x>,<y>,<w>,<h>,<v>

(player direction)

    pd <dx>,<dy>

(player moving)

    pm <dx>,<t/f>

(captured)

    ca <pIdx>,<captured>

(holes left)

    hl <pIdx>,<holesLeft>

(digging)

    di <pIdx>,<t/f>

(won)

    wo <pIdx>

# client -> server

(key down)

    kd <key>

(key up)

    ku <key>
