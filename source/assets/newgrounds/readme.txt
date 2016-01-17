Newgrounds API v3
====================================

For the full API Documentation, see:
http://www.newgrounds.com/wiki/creator-resources/flash-api

API SETTINGS PAGE
-----------------
Create medals, score boards, etc. here:
http://www.newgrounds.com/account/flashapi

FLASH IDE API SETUP
-----------------
Drag the API Connector component onto frame 1 of your movie.
Click on it once, and goto Window->Component Inspector (CS4 and earlier) or Window->Properties (CS5 and later).
Enter your API ID and Encryption Key. You can also tweak other options to your liking.


ACTIONSCRIPT SETUP
-----------------
Add NewgroundsAPI.swc to your library path. Then, to connect to the API:

import com.newgrounds.*;
API.connect(root, "Your API ID", "Your Encryption Key");


UNLOCKING A MEDAL
-----------------

To unlock a medal for a player:

import com.newgrounds.*;
API.unlockMedal("Medal Name");

If the player is a logged-in NG user, the medal should unlock in their profile shortly.
You can use the default NG medal popup by placing the Medal Popup component on your stage. It must be on the stage when the unlockMedal call is made.



POSTING A HIGH SCORE
--------------------

import com.newgrounds.*;
API.postScore("Scoreboard Name", numericScore);

If the player is a logged-in NG user, their score will be submitted.
Only the best score is stored.


VIEWING HIGH SCORES
-------------------
Place the Score Browser on the stage, and type in the scoreboard name into the component parameters.


SAVING A FILE
-------------

import com.newgrounds.*;
var file:SaveFile = API.createSaveFile("Save Group Name");
file.name = "My File";
file.description = "Description";
file.data = {data: foo, moreData: bar};
file.createIcon(icon);
file.save();

file.addEventListener(APIEvent.FILE_SAVED, onFileSaved);
function onFileSave(event:APIEvent) {
	if(event.success)
		trace("File saved!");
}



file.data can be a String, Object, BitmapData, or ByteArray.


LOADING A FILE
--------------

Use the Save Browser component, then listen for FILE_LOADED.

import com.newgrounds.*;
API.addEventListener(APIEvent.FILE_LOADED, onFileLoaded);

function onFileLoaded(event:APIEvent) {
	if(event.success) {
		var file:SaveFile = com.newgrounds.SaveFile(event.data);
		trace("File loaded: " + file.name);
		// file.data contains the data
	}
}