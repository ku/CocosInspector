CocosInspector
==============

cocos2d-iphone server for chrome inspector

put init code in application delegate or somewhere
>#import "CocosInspector.h"
>[[CocosInspector alloc] initWithPort:9223];

open project navigator
drag and drop CocosInspector project file into it
select project file in project navigator
add CocosInspector project to target dependencies in build phases
add libCocosInspector.a to Link Binary with Libraries

add CocosInspector path to user include path

>git clone git@github.com:ku/CocosInspector.git
>git submodule init
>git submodule update

Launch Google Chrome Canary build (https://www.google.com/intl/en/chrome/browser/canary.html) and launch it with --remote-debugging-port option
>  /Applications/Google\ Chrome\ Canary.app//Contents/MacOS//Google\ Chrome\ Canary --remote-debugging-port=9222
  then Canary build starts serving inspector component files(html,css,js,etc) at http://localhost:9222/
  
Run RTSGame in simulator
>  Cocos Inspector runs websocket server on port 9223
  
Access http://localhost:9222/devtools/devtools.html?ws=localhost:9223/ with Chrome
  Chrome reads HTML&js from Canary build and work with data retrieved through websocket server running on port 9223.
