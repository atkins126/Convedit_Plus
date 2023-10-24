//
// Helper functions, utilities, etc.
//
unit ConvEditPlus_Util;

interface

uses
     Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils;

function StringStartsFromDigit(str: String): Boolean;
function IsInvalidFName(const AString: string): Boolean;

implementation

function StringStartsFromDigit(str: String): Boolean;
begin
    if (Length(str) > 0) and (CharInSet(str[1], ['0'..'9'])) then Result := True
       else Result := False;
end;

function IsInvalidFName(const AString: string): Boolean;
begin
    Result := false;

    for var i:= 1 to Length(AString) do
    begin
        if not CharInSet(AString[i], ['A'..'Z', 'a'..'z', '0'..'9', '_']) then begin
            Result := true;
            break;
        end;
    end;
end;

end.
