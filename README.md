# ConEditPlus

An attempt to recreate Deus Ex conversation editor (ConEdit/ConvEdit) in Delphi Language (Pascal). 

ToDo list:
* Full support for dark mode/customizable colors
* Fix bugs and exceptions, write error handling for all possible cases
* ~AutoSave~
* ~Only unique event labels~
* ~Insert event~ 
* ~Cut/Copy/Paste~ ~events~/~conversations~ ~to~/~from clipboard~
* ~text wrap~ ~also make it dynamic~ ~for other events?~
* ~search functions~
* ~label checking~
* ~deletion of unused tables entries~
* ~Remove Speech Generator.~
* Implement ConversationPlayer. 


Known bugs I have not fixed yet:
* ~Duplication of Choice leads to "sync" editing of both events. This is because the copy contains pointers to nested objects from an original event.~
* Should be fixed starting from beta 7. ~For unknown reason (at least at the moment), the original ConEdit refuses to load some files, saved or created in ConEditPlus. These files, however, do work just fine in-game, and can be decompiled with DEED. I suppose this due to some "unknown" fields in  the .con files.~


___

* Uses FreeEsVCLComponents: https://github.com/errorcalc/FreeEsVclComponents
* Uses Xml.VerySimple: https://github.com/Dennis1000/verysimplexml

Built with Delphi 11.3

Compatible with [Windows XP .. Windows 11]

<details> 
  <summary>Screenshot</summary>

The program is working under Windows XP (using virual machine), but there is some problem rendering TProgressBar. Everything else seems to be working fine. 
The program crashes under Windows 2000, so this OS has been removed from compatibilty list.
  
![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/9129ad5c-194b-4a7d-a4aa-0ae519d45a3e)

</details>


Enhancements over OG ConEdit:
* Portable -- only single .exe file and all configuration data stored in .ini file. Does not uses System Registry. No more messing with .ocx files!
* Customizable -- you can use dark mode or/and change some colors.
* Supports scrolling with mouse wheel!
* Extended search. DblClick one of items in the list to jump to it.
* Label verification. DblClick on item to jump to event which refers to invalid label
* Tables. Added presets, and you can add own presets. Check the 'ActorsPawns_Custom.txt' file for details.
* Playing audio file now really works.
* Supports XML files generated by [ConEditExport](https://www.moddb.com/mods/confix/downloads/coneditexport) tool. You can load .XML and save as .CON and vice versa.
* AutoSave. From 1 to 20 minutes. Can be disabled if you don't need it. Disabled by default.
* "AI Tools". A set of command to simplify creation of voiceover using AI, such as ElevenLabs.
* ...and other enhancements and improvements...


How to get the "play audio" function to work:

Open the program options and point to the path where your audio files are. For example, I'm working with the GameConversations package located in `C:\Games\DeusEx_RTX\` 

So the correct path will look like `C:\Games\DeusEx_RTX\GameConversations\Audio`.
![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/8cafd54f-1a88-492e-a322-96028ab323c7)





<details> 
  <summary>Screenshot of main window with loaded conversations file:</summary>
  
![image](https://github.com/user-attachments/assets/3e4d5187-c0cb-41d0-841e-8cdf6123bd64)

  
</details>


<details> 
  <summary>Search:</summary>

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/2591cb79-8e34-46fe-9bba-259d3579c246)

</details>


<details> 
  <summary>Label verification:</summary>

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/2795e541-f871-4ae4-8eae-e8aef114f496)

</details> 

<details> 
  <summary>Enhanced 'Tables' window:</summary>

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/d512c738-6c02-41aa-804f-99909df3d93a)

</details> 

<details> 
  <summary>Duplicate Event and Expand Tree with/without flags:</summary>

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/4905b818-cc86-4417-b29c-f4f4ed13cb03) ![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/f3534f14-6f88-464a-b0d6-5ea5ec5bda97)


</details> 

<details> 
  <summary>How to build from sources:</summary>

* Install Delphi 11.3 or Delphi Community Edition 11.3. Community edition is free.
* Install [CNWizards](https://github.com/cnpack/cnwizards) (optional). 
* Download and install FreeEsVCLComponents components library.
* Download and install the Xml.VerySimple.
* Download sources, open the .dproj file and hit F9 (by default).

</details> 
