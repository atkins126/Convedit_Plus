# Convedit_Plus

An attempt to recreate Deus Ex conversation editor (ConEdit or ConvEdit) in Delphi Language (Pascal). 

what in __NOT__ implemented yet:
* Insert event
* text wrap
* ~search functions~
* ~label checking~
* ~deletion of unused tables entries~
* and other minor stuff
  
Also some bugs here and there. 

--

* Uses FreeEsVCLComponents: https://github.com/errorcalc/FreeEsVclComponents
* Uses Xml.VerySimple: https://github.com/Dennis1000/verysimplexml

Built with Delphi 11.3

Compatible with [Windows 2000 .. Windows 11]
(not sure about Windows 2000/XP, need to check)


Enhancements over OG ConEdit:
* Portable -- only single .exe file and all configuration data stored in .ini file. Does not uses System Registry. No more messing with .ocx files! 
* Customizable -- you can use dark mode or/and change some colors.
* Supports scrolling with mouse wheel!
* Extended search. DblClick one of items in the list to jump to it.
* Label verification. DblClick on item to jump to event which refers to invalid label
* Tables. Added presets, and you can add own presets. Check the 'ActorsPawns_Custom.txt' file for details.
* Playing audio file now really works.
* ...and other enhancements anf improvements...

Screenshot of main window with loaded conversations file:

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/e215a73f-a3e2-4d45-acfe-cc1eb2442a79)

Search:

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/5d6405d6-fcf6-4249-b6f3-c3d881c8d153)

Label verification:

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/2795e541-f871-4ae4-8eae-e8aef114f496)

Enhanced 'Tables' window:

![изображение](https://github.com/LoadLineCalibration/Convedit_Plus/assets/44388228/d512c738-6c02-41aa-804f-99909df3d93a)





