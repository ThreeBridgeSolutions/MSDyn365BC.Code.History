codeunit 1103 "CA Jnl.-Post Batch"
{
    Permissions = TableData "Cost Journal Batch" = imd;
    TableNo = "Cost Journal Line";

    trigger OnRun()
    begin
        CostJnlLine.Copy(Rec);
        Code;
        Rec := CostJnlLine;
    end;

    var
        CostJnlLine: Record "Cost Journal Line";
        CostReg: Record "Cost Register";
        CostRegNo: Integer;
        SuppressCommit: Boolean;
        Text001: Label 'Journal Batch Name    #1##########\\Checking lines        #2######\Posting lines         #3###### @4@@@@@@@@@@@@@';
        Text002: Label 'The lines in Cost Journal are out of balance by %1. Verify that %2 and %3 are correct for each line.';

    local procedure "Code"()
    var
        CostJnlTemplate: Record "Cost Journal Template";
        CostJnlBatch: Record "Cost Journal Batch";
        CAJnlCheckLine: Codeunit "CA Jnl.-Check Line";
        CAJnlPostLine: Codeunit "CA Jnl.-Post Line";
        Window: Dialog;
        StartLineNo: Integer;
        LineCount: Integer;
        NoOfRecords: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCode(CostJnlLine, CostReg, SuppressCommit, IsHandled);
        if IsHandled then
            exit;

        with CostJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            LockTable;

            CostJnlTemplate.Get("Journal Template Name");
            CostJnlBatch.Get("Journal Template Name", "Journal Batch Name");

            if not Find('=><') then begin
                "Line No." := 0;
                if not SuppressCommit then
                    Commit;
                exit;
            end;

            Window.Open(Text001);
            Window.Update(1, "Journal Batch Name");

            // Check lines
            LineCount := 0;
            StartLineNo := "Line No.";
            repeat
                LineCount := LineCount + 1;
                Window.Update(2, LineCount);
                CAJnlCheckLine.RunCheck(CostJnlLine);
                if Next = 0 then
                    FindFirst;
            until "Line No." = StartLineNo;
            NoOfRecords := LineCount;

            // CheckBalance
            CheckBalance;

            CostReg.LockTable;
            if CostReg.FindLast then
                CostRegNo := CostReg."No." + 1
            else
                CostRegNo := 1;

            // Post lines
            LineCount := 0;
            FindSet;
            repeat
                LineCount := LineCount + 1;
                Window.Update(3, LineCount);
                Window.Update(4, Round(LineCount / NoOfRecords * 10000, 1));
                CAJnlPostLine.RunWithCheck(CostJnlLine);
            until Next = 0;

            if not CostReg.FindLast or (CostReg."No." <> CostRegNo) then
                CostRegNo := 0;
            Init;
            "Line No." := CostRegNo;
            OnAfterAssignCostRegNo(CostJnlLine, CostReg, CostRegNo);

            if CostJnlBatch."Delete after Posting" then
                DeleteAll;

            if not SuppressCommit then
                Commit;
        end;

        OnAfterCode(CostJnlLine);
    end;

    local procedure CheckBalance()
    var
        CostJnlLine2: Record "Cost Journal Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckBalance(CostJnlLine, IsHandled);
        if IsHandled then
            exit;

        CostJnlLine.FindSet;
        CostJnlLine2.Copy(CostJnlLine);
        CostJnlLine2.CalcSums(Balance);
        if CostJnlLine2.Balance <> 0 then
            Error(Text002, CostJnlLine2.Balance, CostJnlLine2.FieldCaption("Posting Date"), CostJnlLine2.FieldCaption(Amount));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignCostRegNo(var CostJournalLine: Record "Cost Journal Line"; var CostReg: Record "Cost Register"; CostRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var CostJournalLine: Record "Cost Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var CostJournalLine: Record "Cost Journal Line"; var CostReg: Record "Cost Register"; var SuppressCommit: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBalance(var CostJournalLine: Record "Cost Journal Line"; var IsHandled: Boolean)
    begin
    end;
}

