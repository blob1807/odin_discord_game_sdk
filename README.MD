# Discord Game SDK Bindings
Odin bindings for Discord's [Game SDK](https://discord.com/developers/docs/developer-tools/game-sdk).

## Examples
Translated Discord examples are available in the `examples` folder.

## Usage
1) Download and unzip the `Discord Game SDK v3.2.1` file [provided by Discord](https://discord.com/developers/docs/developer-tools/game-sdk#step-1-get-the-sdk) ([direct link](https://dl-game-sdk.discordapp.net/3.2.1/discord_game_sdk.zip))
2) Place `discord_game_sdk.odin` next to the unzipped folder:
```
discord_game_sdk.odin
discord_game_sdk/
├── lib/
└── ...
```
...or beside the `lib` folder inside it:
```
discord_game_sdk/
├── discord_game_sdk.odin
├── lib/
└── ...
```
3) Since Discord only provides dynamic libraries, copy the library for your target platform next to your application's executable
