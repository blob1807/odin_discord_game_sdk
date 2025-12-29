# Discord Game SDK Bindings
Odin bindings Discord's [Game SDK](https://discord.com/developers/docs/developer-tools/game-sdk).  

## Examples
Translated versions of the examples Dicscord provids can be found in the `examples` folder.

## Using the bindings
Unzip the zip file provied by Discord. Which you can find on the Game SDK [page](https://discord.com/developers/docs/developer-tools/game-sdk) or directly [here](https://dl-game-sdk.discordapp.net/3.2.1/discord_game_sdk.zip).  
`discord_game_sdk.odin` expects to be next to the `./lib` folder in zip or the unziped folder itself.  
```
./odin_discord_game_sdk
  |- discord_game_sdk.odin
  |- ./discord_game_sdk
       |- ./lib
            |- ...

OR

./odin_discord_game_sdk
  |- discord_game_sdk.odin
  |- ./lib
       |- ...
```


The binaries provided by Discord are for dynamic linking. In order to to work, you'll to copy the binary file for your target platform next to your program.  