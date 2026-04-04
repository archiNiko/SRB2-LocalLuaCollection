# Huh?

This is a collection of SRB2 BLua scripts that are namely intended to be used with [SRB2-edit by luigi-budd](https://github.com/luigi-budd/SRB2-edit/), or any build that can load Lua locally (though it's only tested on SRB2-edit unless said otherwise!)

This repository purely exists for making things I'm proud of public, and because I think that gatekeeping them would be counterproductive.

... Fair warning: I don't format well. *PRs are disabled since I wish to use this as a learning curve as well.*

# The Collection

## Local Mute/"Block"
### NOTE: This does not work if an addon redoes chat!

`localmute.lua`: Mute people locally/client side. Adds commands (both prefixed with `bagel_` for the sake of not being overwritten):

`bagel_localmute <a/r/l/w> <player[name/num]>`: Recommended to use playernum, as names are currently finnicky (you need the persons OLD name to unmute them). Argument list:
| Argument | Description |
|-|-|
|   a   |   Add to mute list (Needs player argument)    |
|   r   |   Remove from mute list (Needs player argument)   |
|   l   |   Print the mute list |
|   w   |   Wipe the mute list  |

`bagel_changelocalbool <bool>`: Basically settings toggle. You can execute it for a list. The # of the boolean also works.

| Boolean | Description | Default value
|-|-|-|
|   silenceblocked  | Don't display messages from blocked people in chat    |   on
|   unblockonleave  |   If someone you\'ve muted leaves, remove them from list (AFTER rejointimeout). Heavily recommended to leave enabled  |   on
|   blocklog  | Log messages from blocked people if silenceblocked is on. Saves to /luafiles/client/LOCALMUTE/.    |   on

# Other contact

If you don't wanna open an issue for whatever reason (or don't have GitHub, I guess), slide me a message:

Discord: drstuffdbagel

Matrix: bageltheidiot:matrix.org
