unit ConvEditPlus_Const;

interface

const CEP_CONXML_FILE_VERSION = 28;

// Fonts and their size
const CEP_EVENT_LIST_FONT_NAME = 'Consolas';
const CEP_EVENT_LIST_FONT_SIZE = 10;

const CEP_EVENT_HEADER_LIST_FONT_NAME = 'Tahoma';
const CEP_EVENT_HEADER_LIST_FONT_SIZE = 10;

const CEP_SPEECH_EVENT_FONT = 'Verdana';
const CEP_SPEECH_EVENT_FONT_SIZE = 10;

// maybe temporary?
const CEP_MAX_PLAYABLE_MISSIONS = 97;
const CEP_MAX_RECENT_FILES = 7; //actually 8...
const CEP_MIN_CONVO_TREE_PANEL_WIDTH = 50; { To avoid situation when tree panel has been
                                             reduced to zero and user cannot resize it back.
                                             Works in both directions!}

ResourceString
    ET_Speech_Caption         = 'Speech';
	ET_Choice_Caption         = 'Choice';
	ET_SetFlag_Caption        = 'Set Flags';
	ET_CheckFlag_Caption      = 'Check Flags';
	ET_CheckObject_Caption    = 'Check Object';
	ET_TransferObject_Caption = 'Transfer Object';
	ET_MoveCamera_Caption     = 'Move Camera';
	ET_Animation_Caption      = 'Animation';
	ET_Trade_Caption          = 'Trade';
	ET_Jump_Caption           = 'Jump';
	ET_Random_Caption         = 'Random Label';
	ET_Trigger_Caption        = 'Trigger';
	ET_AddGoal_Caption        = 'Add Goal';
	ET_AddNote_Caption        = 'Add Note';
	ET_AddSkillPoints_Caption = 'Add Skill Points';
	ET_AddCredits_Caption     = 'Add Credits';
	ET_CheckPersona_Caption   = 'Check Persona';
	ET_Comment_Caption        = 'Comment';
	ET_End_Caption            = 'End';
    // The ET_ strings above should not be translated (I doubt if someone will ever need that!)
    ET_Random_TargetLabels = 'Target labels:';

    // for Table.pas
    strActorsPawns = 'Actors/Pawns';
    strFlags = 'Flags';
    strSkills = 'Skills';
    strObjects = 'Objects';
    strAskRemoveUnused = 'Are you sure you wish to remove any unused table entries?';
    strAskRemoveUnusedTitle = 'Remove unused entries?';

    // for events list
    strPrimaryGoal = '(Primary Goal)';
    strGoalCompleted = '(Goal Completed)';
    strGoalName = 'Goal Name: ';
    strGoalText = 'Goal Text: ';

    strAddSkillPoints = 'Add %d SkillPoints';
    strAddCredits = 'Add %d Credits';
    strSubtractCredits = 'Subtract %d Credits';




implementation

end.
