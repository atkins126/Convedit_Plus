//
// ToDo: ����������� �������� �� MainWindow.pas � ������� �� ��� ��������...
//

unit ConXML.Service;

interface

uses
    System.SysUtils, xml.VerySimple, Conversation.Classes, MainWindow, Vcl.ComCtrls, Vcl.Dialogs;


procedure LoadConXMLHeader(const aFile: string); // XML mode
procedure LoadConXMLConversations(const aFile: string);

procedure ReadConvoInfo(conInfoNode: TXmlNode; conversation: TConversation);
procedure ReadConvoParameters(conParamsInfoNode: TXmlNode; conversation: TConversation); // conversation flags, like OnlyOnce, Distance, etc.
procedure ReadConvoFlags(conFlagsNode: TXmlNode; conversation: TConversation);

// events...
procedure ReadSpeech(conSpeechNode: TXmlNode; speechEvent: TConEventSpeech);
procedure ReadChoice(conChoiceNode: TXmlNode; choiceEvent: TConEventChoice);
procedure ReadSetFlags(conSetFlags: TXmlNode; setFlagsEvent: TConEventSetFlag);


procedure BuildConXMLFile(aFile: string);

procedure ReadConBinHeader(const aFile: string); // .Con file mode
procedure ReadConBinData(aFile: string);
procedure BuildConBinFile(aFile: string);


implementation

procedure LoadConXMLHeader(const aFile: string);
var
    actorsNode, flagsNode,
    skillsNode, objectsNode,
    parametersNode,
    missionsArray, RootNode: TXmlNode;

    conXMLDocLocal: TXmlVerySimple;
begin
    with frmMain do
    begin
    ConvoTree.Items.Clear();
    ConEventList.Clear();
    ConversationsList.Clear();
    conFileParameters.Clear();
    conXMLDocLocal:= TXmlVerySimple.Create();
    conXMLDocLocal.Encoding := 'windows-1251';
    conXMLDocLocal.Options := [doCaseInsensitive];
try
    conXMLDocLocal.LoadFromFile(aFile);
    StatusBar.Panels[1].Text := aFile;

    RootNode := conXMLDocLocal.DocumentElement;
    parametersNode := RootNode.Find('Parameters'); // parameters node

    // read and fill parameters
    for var i:=0 to parametersNode.ChildNodes.Count -1 do
    begin
        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('fileVersion') then
           conFileParameters.fpFileVersion := parametersNode.ChildNodes[i].NodeValue.ToInteger;

        if parametersNode.ChildNodes[i].Name = 'createdBy' then  // Creator and date
        begin
           conFileParameters.fpCreatedByName := parametersNode.ChildNodes[i].Find('Name').NodeValue;
           conFileParameters.fpCreatedByDate := parametersNode.ChildNodes[i].Find('Date').NodeValue;
        end;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('modifiedBy') then  // who modified and date
        begin
           conFileParameters.fpModifiedByName := parametersNode.ChildNodes[i].Find('Name').NodeValue;
           conFileParameters.fpModifiedByDate := parametersNode.ChildNodes[i].Find('Date').NodeValue;
        end;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('audioPackage') then  // Audio Package
           conFileParameters.fpAudioPackage := parametersNode.ChildNodes[i].NodeValue;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('notes') then  // Notes
           conFileParameters.fpNotes := parametersNode.ChildNodes[i].NodeValue;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('missions') then  // array of missions
        begin
           missionsArray := parametersNode.ChildNodes[i];

           for var mi:= 0 to missionsArray.ChildNodes.Count -1 do  // set missions in array
           begin
               SetLength(conFileParameters.fpMissions, missionsArray.ChildNodes.Count); // set array length
               conFileParameters.fpMissions[mi] := missionsArray.ChildNodes[mi].NodeValue.ToInteger;
           end;
        end;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('actors') then  // array of Actors/Pawns
        begin
           actorsNode := parametersNode.ChildNodes[i];

           for var act:= 0 to actorsNode.ChildNodes.Count -1 do
           begin
               conFileParameters.fpActors.Insert(
               actorsNode.ChildNodes[act].Attributes['Index'].ToInteger,
               actorsNode.ChildNodes[act].Attributes['Value']);
           end;
        end;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('flags') then  // array of Flags
        begin
           flagsNode := parametersNode.ChildNodes[i];

           for var flg:= 0 to flagsNode.ChildNodes.Count -1 do
           begin
               conFileParameters.fpFlags.Insert(
               flagsNode.ChildNodes[flg].Attributes['Index'].ToInteger,
               flagsNode.ChildNodes[flg].Attributes['Value']);
           end;
        end;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('skills') then  // array of skills
        begin
           skillsNode := parametersNode.ChildNodes[i];

           for var skl:= 0 to skillsNode.ChildNodes.Count -1 do
           begin
               conFileParameters.fpSkills.Insert(
               skillsNode.ChildNodes[skl].Attributes['Index'].ToInteger,
               skillsNode.ChildNodes[skl].Attributes['Value']);
           end;
        end;

        if UpperCase(parametersNode.ChildNodes[i].Name) = UpperCase('objects') then  // array of Objects
        begin
           objectsNode := parametersNode.ChildNodes[i];

           for var obj:= 0 to objectsNode.ChildNodes.Count -1 do
           begin
               conFileParameters.fpObjects.Insert(
               objectsNode.ChildNodes[obj].Attributes['Index'].ToInteger,
               objectsNode.ChildNodes[obj].Attributes['Value']);
           end;
        end;
    end;
    finally
        conXMLDocLocal.Free();
    end;
    end;
end;

procedure LoadConXMLConversations(const aFile: string);
var
    conEventsNode, conversationsNode,
    RootNode, conParamsNode,
    conEventItem: TXmlNode;

    conXMLDocLocal: TXmlVerySimple;
    convoNameStr, ownerNameStr: string;
    tempConvo: TConversation;
    NodeConName, NodeConOwnerName, NodeDependsOnFlags: TTreeNode;
begin
    conXMLDocLocal:= TXmlVerySimple.Create();
    conXMLDocLocal.Encoding := 'windows-1251';
    conXMLDocLocal.Options := [doCaseInsensitive];

try
    conXMLDocLocal.LoadFromFile(aFile);
    RootNode := conXMLDocLocal.DocumentElement;
    conversationsNode := RootNode.Find('Conversations'); // conversations node

    // Now conversations and owners
    for var con:=0 to conversationsNode.ChildNodes.Count -1 do
    begin
        conParamsNode := conversationsNode.ChildNodes[con];
        tempConvo := TConversation.Create();  // Create conversation object
        tempConvo.conName := conParamsNode.Attributes['Name'];

        for var k := 0 to conParamsNode.ChildNodes.Count -1 do
        begin
            if UpperCase(conParamsNode.ChildNodes[k].Name) = UpperCase('id') then
               tempConvo.id:= conParamsNode.ChildNodes[k].NodeValue.ToInteger;

            ReadConvoInfo(conParamsNode.ChildNodes[k], tempConvo); // created, modified, owner
            ReadConvoParameters(conParamsNode.ChildNodes[k], tempConvo);
            ReadConvoFlags(conParamsNode.ChildNodes[k], tempConvo);  // read flags...

            // events...
            if UpperCase(conParamsNode.ChildNodes[k].Name) = UpperCase('Events') then
            begin
                conEventsNode:= conParamsNode.ChildNodes[k];

                for var ET:= 0 to conEventsNode.ChildNodes.Count -1 do
                begin
                    tempConvo.EventsCount:= conEventsNode.ChildNodes.Count;
                    SetLength(tempConvo.Events,tempConvo.EventsCount);

                    conEventItem := conEventsNode.ChildNodes[ET];
                    var EventTypeInt: Integer;
                    var strEventType: string;
                    var tempEvent: TConEvent;
                    var msgStr: String;

                    tempEvent:= nil;

                    EventTypeInt:= conEventsNode.ChildNodes[ET].Attributes['EventType'].ToInteger;
                    strEventType:= conEventsNode.ChildNodes[ET].Attributes['EventTypeName'];

                    // we found the "Speech" event, so let's create and fill it
                    if ((strEventType = 'Speech') and (EventTypeInt = 0)) then
                    begin
                        tempEvent:= TConEventSpeech.Create();
                        ReadSpeech(conEventItem, TConEventSpeech(tempEvent));
                    end;

                    if ((strEventType = 'Choice') and (EventTypeInt = 1)) then
                    begin
                        tempEvent:= TConEventChoice.Create();
                        ReadChoice(conEventItem, TConEventChoice(tempEvent));
                    end;

                    // "Set Flag" event
                    if ((strEventType = 'SetFlag') and (EventTypeInt = 2)) then
                    begin
                        tempEvent:= TConEventSetFlag.Create();
                        ReadSetFlags(conEventItem, TConEventSetFlag(tempEvent));
                    end;
                end;
            end;
        end;
    end;

finally
    conXMLDocLocal.Free();
end;

end;

procedure ReadConvoInfo(conInfoNode: TXmlNode; conversation: TConversation);
begin
    if UpperCase(conInfoNode.Name) = UpperCase('createdBy') then  // who created this conversation
    begin
        for var sn := 0 to conInfoNode.ChildNodes.Count -1 do
        begin
            if UpperCase(conInfoNode.ChildNodes[sn].Name) = UpperCase('name') then
               conversation.conCreatedByName := conInfoNode.ChildNodes[sn].NodeValue;

            if UpperCase(conInfoNode.ChildNodes[sn].Name) = UpperCase('date') then
               conversation.conCreatedByDate := conInfoNode.ChildNodes[sn].NodeValue;
        end;
    end;

    if UpperCase(conInfoNode.Name) = UpperCase('ModifiedBy') then  // who modified this conversation
    begin
        for var sn := 0 to conInfoNode.ChildNodes.Count -1 do
        begin
            if UpperCase(conInfoNode.ChildNodes[sn].Name) = UpperCase('name') then
               conversation.conModifiedByName := conInfoNode.ChildNodes[sn].NodeValue;

            if UpperCase(conInfoNode.ChildNodes[sn].Name) = UpperCase('date') then
               conversation.conModifiedByDate := conInfoNode.ChildNodes[sn].NodeValue;
        end;
    end;

    if UpperCase(conInfoNode.Name) = UpperCase('owner') then  // Conversation owner
    begin
        for var sn := 0 to conInfoNode.ChildNodes.Count -1 do
        begin
            if UpperCase(conInfoNode.ChildNodes[sn].Name) = UpperCase('item') then
            begin
                conversation.conOwnerName := conInfoNode.ChildNodes[sn].Attributes['Value'];
                conversation.conOwnerIndex := conInfoNode.ChildNodes[sn].Attributes['Index'].ToInteger;
            end;
        end;
    end;
end;

procedure ReadConvoParameters(conParamsInfoNode: TXmlNode; conversation: TConversation); // conversation flags, like OnlyOnce, Distance, etc.
begin
    // flags (Infolink, OnlyOnce, etc.)
    if UpperCase(conParamsInfoNode.Name) = UpperCase('infolink') then
        conversation.bInfoLink := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('onlyOnce') then
        conversation.bOnlyOnce := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('firstPerson') then
        conversation.bFirstPerson := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('nonInteract') then
        conversation.bNonInteract := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('randomCamera') then
        conversation.bRandomCamera := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('canInterrupt') then
        conversation.bCanInterrupt := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('canNOTInterrupt') then
        conversation.bCannotInterrupt := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('pcBumps') then
        conversation.bPCBumps := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('pcFrobs') then
        conversation.bPCFrobs := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('npsSees') then
        conversation.bNPCSees := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('npcEnters') then
        conversation.bNPCEnters := StrToBool(conParamsInfoNode.NodeValue);

    if UpperCase(conParamsInfoNode.Name) = UpperCase('distance') then
        conversation.distance := conParamsInfoNode.NodeValue.ToInteger;
end;

procedure ReadConvoFlags(conFlagsNode: TXmlNode; conversation: TConversation);     // now flags...
begin
    if UpperCase(conFlagsNode.Name) = UpperCase('Flags') then
    begin
        // Set length of array and add items to that array.
        SetLength(conversation.conDependsOnFlags, conFlagsNode.ChildNodes.Count);

        for var flg:= 0 to conFlagsNode.ChildNodes.Count -1 do
        begin
            conversation.conDependsOnFlags[flg].flagIndex := conFlagsNode.ChildNodes[flg].Attributes['Index'].ToInteger;
            conversation.conDependsOnFlags[flg].flagName := conFlagsNode.ChildNodes[flg].Attributes['Name'];
            conversation.conDependsOnFlags[flg].flagValue := conFlagsNode.ChildNodes[flg].Attributes['Value'].ToBoolean;
        end;
    end;
end;

procedure ReadSpeech(conSpeechNode: TXmlNode; speechEvent: TConEventSpeech);
begin
    // ������ �� ��������� ���������
    for var U:= 0 to conSpeechNode.ChildNodes.Count -1 do
    begin
        if UpperCase(conSpeechNode.ChildNodes[U].Name) = UpperCase('Label') then
           speechEvent.EventLabel := conSpeechNode.ChildNodes[U].NodeValue;

        // actor
        if UpperCase(conSpeechNode.ChildNodes[U].Name) = UpperCase('Actor') then
        begin
            speechEvent.ActorIndex := conSpeechNode.ChildNodes[U].Find('Item').Attributes['Index'].ToInteger;
            speechEvent.ActorValue := conSpeechNode.ChildNodes[U].Find('Item').Attributes['Value'];
        end;

        // actor to
        if UpperCase(conSpeechNode.ChildNodes[U].Name) = UpperCase('ActorTo') then
        begin
            speechEvent.ActorToIndex := conSpeechNode.ChildNodes[U].Find('Item').Attributes['Index'].ToInteger;
            speechEvent.ActorToValue := conSpeechNode.ChildNodes[U].Find('Item').Attributes['Value'];
        end;

        // speech text
        if UpperCase(conSpeechNode.ChildNodes[U].Name) = UpperCase('TextLine') then
        begin
           speechEvent.TextLine := conSpeechNode.ChildNodes[U].NodeValue;
           speechEvent.LineBreaksCount := frmMain.CountLineBreaks(conSpeechNode.ChildNodes[U].NodeValue);
        end;

        if UpperCase(conSpeechNode.ChildNodes[U].Name) = UpperCase('mp3') then
           speechEvent.mp3File := conSpeechNode.ChildNodes[U].NodeValue;
    end;
end;

procedure ReadChoice(conChoiceNode: TXmlNode; choiceEvent: TConEventChoice);
begin
    for var R:= 0 to conChoiceNode.ChildNodes.Count -1 do
    begin
        if UpperCase(conChoiceNode.ChildNodes[R].Name) = UpperCase('Label') then
           choiceEvent.EventLabel := conChoiceNode.ChildNodes[R].NodeValue;

        if UpperCase(conChoiceNode.ChildNodes[R].Name) = UpperCase('clearScreen') then
           choiceEvent.bClearScreen := conChoiceNode.ChildNodes[R].NodeValue.ToBoolean;

        if UpperCase(conChoiceNode.ChildNodes[R].Name) = UpperCase('Choices') then begin
            var temp_ChoiceItem:= conChoiceNode.ChildNodes[R];

            choiceEvent.NumChoices := temp_ChoiceItem.ChildNodes.Count;

            for var J:= 0 to temp_ChoiceItem.ChildNodes.Count -1 do begin

                var ChoiceField:=temp_ChoiceItem.ChildNodes[J];
                SetLength(choiceEvent.Choices, ChoiceField.ChildNodes.Count);

                for var ci := 0 to ChoiceField.ChildNodes.Count -1 do begin

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('Index') then
                        choiceEvent.Choices[J].Index := ChoiceField.ChildNodes[ci].NodeValue.ToInteger;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('TextLine') then begin
                        choiceEvent.Choices[J].textline := ChoiceField.ChildNodes[ci].NodeValue;
                    end;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('DisplayAsSpeech') then
                        choiceEvent.Choices[J].bDisplayAsSpeech := ChoiceField.ChildNodes[ci].NodeValue.ToBoolean;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('SkillNeeded') then
                        choiceEvent.Choices[J].bSkillNeeded := ChoiceField.ChildNodes[ci].NodeValue.ToInteger;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('Skill') then
                        choiceEvent.Choices[J].Skill := ChoiceField.ChildNodes[ci].NodeValue;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('SkillLevel') then
                        choiceEvent.Choices[J].SkillLevel := ChoiceField.ChildNodes[ci].NodeValue.ToInteger;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('GoToLabel') then
                        choiceEvent.Choices[J].GoToLabel := ChoiceField.ChildNodes[ci].NodeValue;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('mp3') then
                        choiceEvent.Choices[J].mp3 := ChoiceField.ChildNodes[ci].NodeValue;

                    if UpperCase(ChoiceField.ChildNodes[ci].Name) = UpperCase('Flags') then
                    begin
                        SetLength(choiceEvent.Choices[J].RequiredFlags, ChoiceField.ChildNodes[ci].ChildNodes.Count);
                        Inc(choiceEvent.NumFlagsStrings, 1); // add extra 1 so choices and flags will fit into list item

                        for var RF:=0 to High(choiceEvent.Choices[J].RequiredFlags) do
                        begin
                            choiceEvent.Choices[J].RequiredFlags[RF].flagIndex := ChoiceField.ChildNodes[ci].ChildNodes[RF].Attributes['Index'].ToInteger;
                            choiceEvent.Choices[J].RequiredFlags[RF].flagName := ChoiceField.ChildNodes[ci].ChildNodes[RF].Attributes['Name'];
                            choiceEvent.Choices[J].RequiredFlags[RF].flagValue := ChoiceField.ChildNodes[ci].ChildNodes[RF].Attributes['Value'].ToBoolean;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

procedure ReadSetFlags(conSetFlags: TXmlNode; setFlagsEvent: TConEventSetFlag);
begin
    for var U:= 0 to conSetFlags.ChildNodes.Count -1 do
    begin
        if UpperCase(conSetFlags.ChildNodes[U].Name) = UpperCase('Label') then
           setFlagsEvent.EventLabel := conSetFlags.ChildNodes[U].NodeValue;

        if UpperCase(conSetFlags.ChildNodes[U].Name) = UpperCase('Flags') then
        begin
            var temp_Flags:= conSetFlags.ChildNodes[U];
            // set array length
            setFlagsEvent.ArrayLength := temp_Flags.ChildNodes.Count;
            SetLength(setFlagsEvent.SetFlags, temp_Flags.ChildNodes.Count);

            // and fill it
            for var SF := 0 to temp_Flags.ChildNodes.Count -1 do
            begin
               setFlagsEvent.SetFlags[SF].flagIndex := temp_Flags.ChildNodes[SF].Attributes['Index'].ToInteger;
               setFlagsEvent.SetFlags[SF].flagName := temp_Flags.ChildNodes[SF].Attributes['Name'];
               setFlagsEvent.SetFlags[SF].flagValue := temp_Flags.ChildNodes[SF].Attributes['Value'].ToBoolean;

               if temp_Flags.ChildNodes[SF].HasAttribute('Obsolete') then // ������ ��� ������� "Obsolete" ����� �������������, ����� ����������...
                  setFlagsEvent.SetFlags[SF].flagExpiration := temp_Flags.ChildNodes[SF].Attributes['Obsolete'].ToInteger;
            end;
        end;
    end;
end;

procedure BuildConXMLFile(aFile: string); // Create and save XML file
var
    choiceidx: Integer;
begin
    var conXML := TXmlVerySimple.Create();
    conXML.Encoding:= 'windows-1251';
    conXML.Options := [];
    conXML.NodeIndentStr:= #9;
try
    with frmMain do begin

    var rootNode:= conXML.AddChild('DeusExConversationFile', ntElement);
    var ParamsNode:= rootNode.AddChild('Parameters');

        ParamsNode.AddChild('fileVersion').SetText(conFileParameters.fpFileVersion.ToString);

    var createdBy:= ParamsNode.AddChild('createdBy');
        createdBy.AddChild('name').SetText(conFileParameters.fpCreatedByName);
        createdBy.AddChild('date').SetText(conFileParameters.fpCreatedByDate);

    var modifiedBy := ParamsNode.AddChild('modifiedBy');
        modifiedBy.AddChild('name').SetText(conFileParameters.fpModifiedByName);
        modifiedBy.AddChild('date').SetText(conFileParameters.fpModifiedByDate);

    var AudioPack := ParamsNode.AddChild('audioPackage').SetText(conFileParameters.fpAudioPackage);
    var Notes := ParamsNode.AddChild('notes').SetText(' ' + conFileParameters.fpNotes);

    var missions:= ParamsNode.AddChild('missions');
    for var m:=0 to High(ConFileParameters.fpMissions) do
    begin
        missions.AddChild('mission').SetText(m.ToString);
    end;

    var actors:= ParamsNode.AddChild('actors');     // save Actors...
    for var a:=0 to ConFileParameters.fpActors.Count -1 do
    begin
        var actorItem:= actors.AddChild('Item');
        actorItem.SetAttribute('Index', conFileParameters.fpActors.IndexOf(conFileParameters.fpActors[a]).ToString);
        actorItem.SetAttribute('Value', conFileParameters.fpActors[a]);
    end;

    var flags:= ParamsNode.AddChild('flags');     // save Flags...
    for var f:=0 to ConFileParameters.fpFlags.Count -1 do
    begin
        var flagItem:= flags.AddChild('Item');
        flagItem.SetAttribute('Index', conFileParameters.fpFlags.IndexOf(conFileParameters.fpFlags[f]).ToString);
        flagItem.SetAttribute('Value', conFileParameters.fpFlags[f]);
    end;

    var skills:= ParamsNode.AddChild('skills');     // save Skills...
    for var s:=0 to ConFileParameters.fpSkills.Count -1 do
    begin
        var skillItem:= skills.AddChild('Item');
        skillItem.SetAttribute('Index', conFileParameters.fpSkills.IndexOf(conFileParameters.fpSkills[s]).ToString);
        skillItem.SetAttribute('Value', conFileParameters.fpSkills[s]);
    end;

    var objects:= ParamsNode.AddChild('objects');     // save Objects...
    for var o:=0 to ConFileParameters.fpObjects.Count -1 do
    begin
        var objectItem:= objects.AddChild('Item');
        objectItem.SetAttribute('Index', conFileParameters.fpObjects.IndexOf(conFileParameters.fpObjects[o]).ToString);
        objectItem.SetAttribute('Value', conFileParameters.fpObjects[o]);
    end;

    // Save Conversations...
    var ConvosNode:= rootNode.AddChild('Conversations').SetText('');

    for var con := 0 to ConversationsList.Count -1 do
        begin
            var conItem := ConvosNode.AddChild('Conversation');
                conItem.SetAttribute('name', ConversationsList.Items[con].conName);

            var id_item:= conItem.AddChild('id');
                id_item.SetText(ConversationsList.Items[con].id.ToString);

            var con_createdBy := conItem.AddChild('createdBy');
                con_createdBy.AddChild('name').SetText(ConversationsList.Items[con].conCreatedByName);
                con_createdBy.AddChild('date').SetText(ConversationsList.Items[con].conCreatedByDate);

            var con_ModifiedBy:= conItem.AddChild('modifiedBy');
                con_ModifiedBy.AddChild('name').SetText(ConversationsList.Items[con].conModifiedByName);
                con_ModifiedBy.AddChild('date').SetText(ConversationsList.Items[con].conModifiedByDate);

            var Con_Owner:= conItem.AddChild('owner').AddChild('Item');
                Con_Owner.SetAttribute('Index', ConversationsList.Items[con].conOwnerIndex.ToString);
                Con_Owner.SetAttribute('Value', ConversationsList.Items[con].conOwnerName);

                // bools (Infolink, OnlyOnce, etc.)
                conItem.AddChild('infolink').SetText(BoolToStr(ConversationsList.Items[con].bInfoLink, true));
                conItem.AddChild('onlyOnce').SetText(BoolToStr(ConversationsList.Items[con].bOnlyOnce, True));
                conItem.AddChild('firstPerson').SetText(BoolToStr(ConversationsList.Items[con].bFirstPerson, True));
                conItem.AddChild('nonInteract').SetText(BoolToStr(ConversationsList.Items[con].bNonInteract, true));
                conItem.AddChild('randomCamera').SetText(BoolToStr(ConversationsList.Items[con].bRandomCamera, True));
                conItem.AddChild('canInterrupt').SetText(BoolToStr(ConversationsList.Items[con].bCanInterrupt, True));
                conItem.AddChild('canNOTInterrupt').SetText(BoolToStr(ConversationsList.Items[con].bCannotInterrupt, True));
                conItem.AddChild('pcBumps').SetText(BoolToStr(ConversationsList.Items[con].bPCBumps, True));
                conItem.AddChild('pcFrobs').SetText(BoolToStr(ConversationsList.Items[con].bPCFrobs, True));
                conItem.AddChild('npsSees').SetText(BoolToStr(ConversationsList.Items[con].bNPCSees, True));
                conItem.AddChild('npcEnters').SetText(BoolToStr(ConversationsList.Items[con].bNPCEnters, True));

                if ConversationsList.Items[con].distance > 0 then
                   conItem.AddChild('distance').SetText(ConversationsList.Items[con].distance.ToString);


              var Con_Flags := conItem.AddChild('flags');             // Conversation flags...
              for var flgIdx:= 0 to High(ConversationsList.Items[con].conDependsOnFlags) do
              begin
                  var flag_item := Con_Flags.AddChild('Flag');
                      flag_item.SetAttribute('index',ConversationsList.Items[con].conDependsOnFlags[flgIdx].flagIndex.ToString);
                      flag_item.SetAttribute('Name', ConversationsList.Items[con].conDependsOnFlags[flgIdx].flagName);
                      flag_item.SetAttribute('Value', BoolToStr(ConversationsList.Items[con].conDependsOnFlags[flgIdx].flagValue, True));
              end;

              var Con_Events:= conItem.AddChild('Events').SetText('');             // Conversation events...
              for var eventidx:= 0 to High(ConversationsList.Items[con].Events) do
              begin
                  var ConEvent:= Con_Events.AddChild('Event');
                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Speech then
                      begin
                         ConEvent.SetAttribute('EventType', '0');
                         ConEvent.SetAttribute('EventTypeName', 'Speech');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var ActorFrom := ConEvent.AddChild('actor').AddChild('Item');
                             ActorFrom.SetAttribute('Index', TConEventSpeech(ConversationsList.Items[con].Events[eventidx]).ActorIndex.ToString);
                             ActorFrom.SetAttribute('Value', TConEventSpeech(ConversationsList.Items[con].Events[eventidx]).ActorValue);

                         var ActorTo := ConEvent.AddChild('actorTo').AddChild('Item');
                             ActorTo.SetAttribute('Index', TConEventSpeech(ConversationsList.Items[con].Events[eventidx]).ActorToIndex.ToString);
                             ActorTo.SetAttribute('Value', TConEventSpeech(ConversationsList.Items[con].Events[eventidx]).ActorToValue);

                         ConEvent.AddChild('textLine').SetText(TConEventSpeech(ConversationsList.Items[con].Events[eventidx]).TextLine);
                         ConEvent.AddChild('mp3').SetText(TConEventSpeech(ConversationsList.Items[con].Events[eventidx]).mp3File);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Choice then
                      begin
                         ConEvent.SetAttribute('EventType', '1');
                         ConEvent.SetAttribute('EventTypeName', 'Choice');

                         var ChoiceEvent := TConEventChoice(ConversationsList.Items[con].Events[eventidx]);

                         if ChoiceEvent.EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ChoiceEvent.EventLabel);

                            ConEvent.AddChild('clearScreen').SetText(BoolToStr(ChoiceEvent.bClearScreen, true));

                         var ChoicesBranch:= ConEvent.AddChild('Choices');

                           for choiceidx:= 0 to ChoiceEvent.NumChoices -1 do
                           begin
                              var Choice := ChoiceEvent.Choices[choiceidx];

                              //ShowMessage(Length(ChoiceEvent.Choices).ToString);

                              var choiceItem:= ChoicesBranch.AddChild('Choice');
                                  choiceItem.AddChild('index').SetText(Choice.Index.ToString);
                                  choiceItem.AddChild('textLine').SetText(Choice.textline);
                                  choiceItem.AddChild('displayAsSpeech').SetText(BoolToStr(Choice.bDisplayAsSpeech, True));
                                  choiceItem.AddChild('skillNeeded').SetText(Choice.bSkillNeeded.ToString);
                                  choiceItem.AddChild('skill').SetText(Choice.Skill);
                                  choiceItem.AddChild('skillLevel').SetText(Choice.SkillLevel.ToString);
                                  choiceItem.AddChild('gotoLabel').SetText(Choice.GoToLabel);
                                  choiceItem.AddChild('mp3').SetText(Choice.mp3);

                                  var choiceFlags:= choiceItem.AddChild('flags');

                                  for var flgidx := 0 to High(Choice.RequiredFlags) do begin

                                      var flag := Choice.RequiredFlags[flgidx];
                                      var choiceFlag := choiceFlags.AddChild('Flag');

                                      choiceFlag.SetAttribute('index', flag.flagIndex.ToString);
                                      choiceFlag.SetAttribute('Name', flag.flagName);
                                      choiceFlag.SetAttribute('Value', BoolToStr(flag.flagValue, true));
                                  end;
                           end;
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_SetFlag then
                      begin
                         ConEvent.SetAttribute('EventType', '2');
                         ConEvent.SetAttribute('EventTypeName', 'SetFlag');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var flags_branch:= ConEvent.AddChild('flags');
                         var SetFlagsEvent := TConEventSetFlag(ConversationsList.Items[con].Events[eventidx]);

                           for var sfIndex:= 0 to High(SetFlagsEvent.SetFlags) do
                           begin

                               var flag_item:= flags_branch.AddChild('Flag');
                                   flag_item.SetAttribute('index', SetFlagsEvent.SetFlags[sfIndex].flagIndex.ToString);
                                   flag_item.SetAttribute('Name', SetFlagsEvent.SetFlags[sfIndex].flagName);
                                   flag_item.SetAttribute('Value', BoolToStr(SetFlagsEvent.SetFlags[sfIndex].flagValue, true));
                                   flag_item.SetAttribute('Obsolete', SetFlagsEvent.SetFlags[sfIndex].flagExpiration.ToString);
                           end;
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_CheckFlag then
                      begin
                         ConEvent.SetAttribute('EventType', '3');
                         ConEvent.SetAttribute('EventTypeName', 'CheckFlag');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var flags_branch:= ConEvent.AddChild('flags');
                         var CheckFlagsEvent := TConEventCheckFlag(ConversationsList.Items[con].Events[eventidx]);

                         for var cfIndex:= 0 to High(CheckFlagsEvent.FlagsToCheck) do
                         begin
                             var chkflag_item:= flags_branch.AddChild('Flag');
                                 chkflag_item.SetAttribute('index', CheckFlagsEvent.FlagsToCheck[cfIndex].flagIndex.ToString);
                                 chkflag_item.SetAttribute('Name', CheckFlagsEvent.FlagsToCheck[cfIndex].flagName);
                                 chkflag_item.SetAttribute('Value', BoolToStr(CheckFlagsEvent.FlagsToCheck[cfIndex].flagValue, true));
                         end;
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_CheckObject then
                      begin
                         ConEvent.SetAttribute('EventType', '4');
                         ConEvent.SetAttribute('EventTypeName', 'CheckObject');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var CheckObjectEvent:= TConEventCheckObject(ConversationsList.Items[con].Events[eventidx]);

                         var objectItem:= ConEvent.AddChild('object').AddChild('Item');
                             objectItem.SetAttribute('Index', CheckObjectEvent.ObjectIndex.ToString);
                             objectItem.SetAttribute('Value', CheckObjectEvent.ObjectValue);

                         ConEvent.AddChild('gotoLabel').SetText(CheckObjectEvent.GoToLabel);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_TransferObject then
                      begin

                         ConEvent.SetAttribute('EventType', '5');
                         ConEvent.SetAttribute('EventTypeName', 'TransferObject');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var TransferObjectEvent:= TConEventTransferObject(ConversationsList.Items[con].Events[eventidx]);

                         var ObjectToTransfer:= ConEvent.AddChild('object').AddChild('Item');
                             ObjectToTransfer.SetAttribute('Index', TransferObjectEvent.ObjectIndex.ToString);
                             ObjectToTransfer.SetAttribute('Value', TransferObjectEvent.ObjectValue);

                         ConEvent.AddChild('amount').SetText(TransferObjectEvent.Amount.ToString);

                         var ActorFrom:= ConEvent.AddChild('actorFrom').AddChild('Item');
                             ActorFrom.SetAttribute('Index', TransferObjectEvent.ActorFromIndex.ToString);
                             ActorFrom.SetAttribute('Value', TransferObjectEvent.ActorFromValue);

                         var ActorTo:= ConEvent.AddChild('actorTo').AddChild('Item');
                             ActorTo.SetAttribute('Index', TransferObjectEvent.ActorToIndex.ToString);
                             ActorTo.SetAttribute('Value', TransferObjectEvent.ActorToValue);

                         ConEvent.AddChild('gotoLabel').SetText(TransferObjectEvent.GotoLabel);

                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_MoveCamera then
                      begin
                         ConEvent.SetAttribute('EventType', '6');
                         ConEvent.SetAttribute('EventTypeName', 'MoveCamera');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var MoveCamEvent:= TConEventMoveCamera(ConversationsList.Items[con].Events[eventidx]);

                             ConEvent.AddChild('type').SetText(Ord(MoveCamEvent.CameraType).ToString);
                             ConEvent.AddChild('angle').SetText(Ord(MoveCamEvent.CameraAngle).ToString);
                             ConEvent.AddChild('transition').SetText(Ord(MoveCamEvent.CameraTransition).ToString);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Animation then
                      begin
                         ConEvent.SetAttribute('EventType', '7');
                         ConEvent.SetAttribute('EventTypeName', 'Animation');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var PlayAnimEvent:= TConEventAnimation(ConversationsList.Items[con].Events[eventidx]);

                         var PlayAnimActor:= ConEvent.AddChild('actor').AddChild('Item');
                             PlayAnimActor.SetAttribute('Index', PlayAnimEvent.ActorIndex.ToString);
                             PlayAnimActor.SetAttribute('Value', PlayAnimEvent.ActorValue);

                             ConEvent.AddChild('sequence').SetText(PlayAnimEvent.AnimSequence);
                             ConEvent.AddChild('playOnce').SetText(PlayAnimEvent.bAnimPlayOnce.ToString);
                             ConEvent.AddChild('playForSeconds').SetText(PlayAnimEvent.AnimPlayForSeconds.ToString);
                             ConEvent.AddChild('waitToFinish').SetText(BoolToStr(PlayAnimEvent.bAnimWaitToFinish, True));
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Trade then
                      begin
                         ConEvent.SetAttribute('EventType', '8');
                         ConEvent.SetAttribute('EventTypeName', 'Trade');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Jump then
                      begin

                         ConEvent.SetAttribute('EventType', '9');
                         ConEvent.SetAttribute('EventTypeName', 'Jump');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var JumpEvent:= TConEventJump(ConversationsList.Items[con].Events[eventidx]);

                            ConEvent.AddChild('gotoLabel').SetText(JumpEvent.gotoLabel);
                            ConEvent.AddChild('conversationId').SetText(JumpEvent.conversationId.ToString);
                            ConEvent.AddChild('currentConversationId').SetText(JumpEvent.currentConversationId.ToString);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Random then
                      begin

                         ConEvent.SetAttribute('EventType', '10');
                         ConEvent.SetAttribute('EventTypeName', 'Random');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var RandomEvent:= TConEventRandom(ConversationsList.Items[con].Events[eventidx]);
                         var RandomBranch:= ConEvent.AddChild('gotoLabels');

                         for var rndidx:=0 to High(RandomEvent.GoToLabels) do
                             var RandomLabel:= RandomBranch.AddChild('gotoLabel').SetText(RandomEvent.GoToLabels[rndidx]);


                         ConEvent.AddChild('cycle').SetText(BoolToStr(RandomEvent.bCycle, True));
                         ConEvent.AddChild('cycleOnce').SetText(BoolToStr(RandomEvent.bCycleOnce, True));
                         ConEvent.AddChild('cycleRandom').SetText(BoolToStr(RandomEvent.bCycleRandom, True));
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Trigger then
                      begin

                         ConEvent.SetAttribute('EventType', '11');
                         ConEvent.SetAttribute('EventTypeName', 'Trigger');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         ConEvent.AddChild('triggerTag').SetText(TConEventTrigger(ConversationsList.Items[con].Events[eventidx]).TriggerTag);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_AddGoal then
                      begin

                         ConEvent.SetAttribute('EventType', '12');
                         ConEvent.SetAttribute('EventTypeName', 'AddGoal');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var GoalEvent:= TConEventAddGoal(ConversationsList.Items[con].Events[eventidx]);

                            ConEvent.AddChild('name').SetText(GoalEvent.GoalName);
                            ConEvent.AddChild('complete').SetText(BoolToStr(GoalEvent.bComplete, True));
                            ConEvent.AddChild('textLine').SetText(GoalEvent.GoalText);
                            ConEvent.AddChild('primary').SetText(BoolToStr(GoalEvent.bPrimaryGoal, True));
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_AddNote then
                      begin

                         ConEvent.SetAttribute('EventType', '13');
                         ConEvent.SetAttribute('EventTypeName', 'AddNote');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                            ConEvent.AddChild('textLine').SetText(TConEventAddNote(ConversationsList.Items[con].Events[eventidx]).TextLine);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_AddSkillPoints then
                      begin

                         ConEvent.SetAttribute('EventType', '14');
                         ConEvent.SetAttribute('EventTypeName', 'AddSkillPoints');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var EventAddSkillPoints:= TConEventAddSkillPoints(ConversationsList.Items[con].Events[eventidx]);

                            ConEvent.AddChild('points').SetText(EventAddSkillPoints.Points.ToString);
                            ConEvent.AddChild('textLine').SetText(EventAddSkillPoints.TextLine);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_AddCredits then
                      begin

                         ConEvent.SetAttribute('EventType', '15');
                         ConEvent.SetAttribute('EventTypeName', 'AddCredits');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                            ConEvent.AddChild('points').SetText(TConEventAddCredits(ConversationsList.Items[con].Events[eventidx]).Credits.ToString);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_CheckPersona then
                      begin

                         ConEvent.SetAttribute('EventType', '16');
                         ConEvent.SetAttribute('EventTypeName', 'CheckPersona');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         var EventCheckPersona:= TConEventCheckPersona(ConversationsList.Items[con].Events[eventidx]);

                             ConEvent.AddChild('object').SetText(Ord(EventCheckPersona.AttrToCheck).ToString);
                             ConEvent.AddChild('relation').SetText(Ord(EventCheckPersona.Condition).ToString);
                             ConEvent.AddChild('value').SetText(EventCheckPersona.CheckValue.ToString);
                             ConEvent.AddChild('gotoLabel').SetText(EventCheckPersona.CheckGoToLabel);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_Comment then
                      begin

                         ConEvent.SetAttribute('EventType', '17');
                         ConEvent.SetAttribute('EventTypeName', 'Comment');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);

                         ConEvent.AddChild('textLine').SetText(TConEventComment(ConversationsList.Items[con].Events[eventidx]).TextLine);
                      end;

                      if ConversationsList.Items[con].Events[eventidx].EventType = ET_End then
                      begin

                         ConEvent.SetAttribute('EventType', '18');
                         ConEvent.SetAttribute('EventTypeName', 'End');

                         if ConversationsList.Items[con].Events[eventidx].EventLabel <> '' then
                            ConEvent.AddChild('Label').SetText(ConversationsList.Items[con].Events[eventidx].EventLabel);
                      end;

              end;
        end;
    end;

    conXML.SaveToFile(aFile);
finally
    conXML.Free();
end;
end;


procedure ReadConBinHeader(const aFile: string);
begin
//
end;

procedure ReadConBinData(aFile: string);
begin
//
end;

procedure BuildConBinFile(aFile: string);
begin
//
end;

end.