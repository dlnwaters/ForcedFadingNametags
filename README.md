# Forced Fading Nametags

Server plugin and BeamMP client mod that forces BeamMP's distance fade for player nametags using server-sided settings.

## What it does

The server sends the config to the client upon joining, forces UI config onto the client, it resets the clients UI when they leave

## Installation

Copy `Resources` folder into the matching `Resources` folders of a BeamMP server.

##Config

Edit `Resources/Server/ForcedFadingNametags/config.json`

##References

- [BeamMP server Lua reference](https://docs.beammp.com/scripting/server/latest-server-reference/)
- [BeamMP server mod installation structure](https://docs.beammp.com/guides/mod-creation/server/getting-started/)
- [BeamMP client scripting reference](https://docs.beammp.com/scripting/mod-reference/)
- [BeamMP client API, including vehicle and nametag functions](https://docs.beammp.com/API%20documentation/Client-Side/)
- [BeamMP multiplayer nametag settings](https://docs.beammp.com/game/multiplayer-settings/)
- [BeamMP MPVehicleGE renderer source](https://github.com/BeamMP/BeamMP/blob/development/lua/ge/extensions/MPVehicleGE.lua)

