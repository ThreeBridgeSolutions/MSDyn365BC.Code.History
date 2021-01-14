codeunit 132479 "Posting Codeunit Mock"
{
    // OnRun trigger expects "Error Message" records that define order of events depends on "Message Type":
    // - "Message Type"::Warning will initiate logging of an error;
    // - "Message Type"::Error will throw unhandled error;
    // - "Message Type"::Information will execute
    // Different combinations of these records should simulate actual situations that are to be handled.

    TableNo = "Error Message";

    trigger OnRun()
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
        MsgType: Integer;
    begin
        ContextID := 0;
        FindSet;
        repeat
            MsgType := "Message Type";
            case MsgType of
                -3: // pop context
                    begin
                        UnbindSubscription(ErrorContextElement[ContextID]);
                        ContextID -= 1;
                    end;
                -2: // Error in local context
                    LogLocalError("Record ID", Description, "Additional Information");
                -1: // global context
                    ContextID :=
                      ErrorMessageMgt.PushContext(ErrorContextElement[ContextID + 1], "Context Record ID", "Context Field Number", Description);
                "Message Type"::Warning:
                    ErrorMessageMgt.LogError("Record ID", Description, '');
                "Message Type"::Error:
                    Error(Description);
                "Message Type"::Information:
                    ErrorMessageMgt.Finish("Context Record ID");
            end;
        until Next = 0;
    end;

    var
        ErrorContextElement: array[2] of Codeunit "Error Context Element";
        ContextID: Integer;

    local procedure LogLocalError(RecID: RecordID; Description: Text[250]; AddInfo: Text[250])
    var
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageMgt: Codeunit "Error Message Management";
    begin
        ContextID := ErrorMessageMgt.PushContext(ErrorContextElement, 0, 0, AddInfo);
        ErrorMessageMgt.LogError(RecID, Description, '');
    end;

    procedure RunWithActiveErrorHandling(var TempErrorMessage: Record "Error Message" temporary): Boolean
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        PostingCodeunitMock: Codeunit "Posting Codeunit Mock";
    begin
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        Commit;
        if not PostingCodeunitMock.Run(TempErrorMessage) then
            exit(ErrorMessageHandler.ShowErrors);
    end;

    procedure TryRun(var TempErrorMessage: Record "Error Message" temporary): Boolean
    var
        PostingCodeunitMock: Codeunit "Posting Codeunit Mock";
    begin
        Commit;
        exit(PostingCodeunitMock.Run(TempErrorMessage));
    end;
}

