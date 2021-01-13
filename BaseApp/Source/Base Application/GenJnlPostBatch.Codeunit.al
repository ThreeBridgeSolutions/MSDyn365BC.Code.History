codeunit 13 "Gen. Jnl.-Post Batch"
{
    Permissions = TableData "Gen. Journal Batch" = imd;
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Copy(Rec);
        GenJnlLine.SetAutoCalcFields;
        Code(GenJnlLine);
        Rec := GenJnlLine;
    end;

    var
        PostingStateMsg: Label 'Journal Batch Name    #1##########\\Posting @2@@@@@@@@@@@@@\#3#############', Comment = 'This is a message for dialog window. Parameters do not require translation.';
        CheckingLinesMsg: Label 'Checking lines';
        CheckingBalanceMsg: Label 'Checking balance';
        UpdatingBalLinesMsg: Label 'Updating bal. lines';
        PostingLinesMsg: Label 'Posting lines';
        PostingReversLinesMsg: Label 'Posting revers. lines';
        UpdatingLinesMsg: Label 'Updating lines';
        Text008: Label 'must be the same on all lines for the same document';
        Text009: Label '%1 %2 posted on %3 includes more than one customer or vendor. ';
        Text010: Label 'In order for the program to calculate VAT, the entries must be separated by another document number or by an empty line.';
        Text012: Label '%5 %2 is out of balance by %1. ';
        Text013: Label 'Please check that %3, %4, %5 and %6 are correct for each line.';
        Text014: Label 'The lines in %1 are out of balance by %2. ';
        Text015: Label 'Check that %3 and %4 are correct for each line.';
        Text016: Label 'Your reversing entries in %4 %2 are out of balance by %1. ';
        Text017: Label 'Please check whether %3 is correct for each line for this %4.';
        Text018: Label 'Your reversing entries for %1 are out of balance by %2. ';
        Text019: Label '%3 %1 is out of balance due to the additional reporting currency. ';
        Text020: Label 'Please check that %2 is correct for each line.';
        Text021: Label 'cannot be specified when using recurring journals.';
        Text022: Label 'The Balance and Reversing Balance recurring methods can be used only for G/L accounts.';
        Text023: Label 'Allocations can only be used with recurring journals.';
        Text024: Label '<Month Text>';
        Text025: Label 'A maximum of %1 posting number series can be used in each journal.';
        Text026: Label '%5 %2 is out of balance by %1 %7. ';
        Text027: Label 'The lines in %1 are out of balance by %2 %5. ';
        Text028: Label 'The Balance and Reversing Balance recurring methods can be used only with Allocations.';
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlLine3: Record "Gen. Journal Line";
        TempGenJnlLine4: Record "Gen. Journal Line" temporary;
        GenJnlLine5: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        GLReg: Record "G/L Register";
        GLAcc: Record "G/L Account";
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
        AccountingPeriod: Record "Accounting Period";
        NoSeries: Record "No. Series" temporary;
        GLSetup: Record "General Ledger Setup";
        FAJnlSetup: Record "FA Journal Setup";
        GenJnlLineTemp: Record "Gen. Journal Line" temporary;
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        ICOutboxMgt: Codeunit ICInboxOutboxMgt;
        PostingSetupMgt: Codeunit PostingSetupManagement;
        Window: Dialog;
        GLRegNo: Integer;
        StartLineNo: Integer;
        StartLineNoReverse: Integer;
        LastDate: Date;
        LastDocType: Option;
        LastDocNo: Code[20];
        LastPostedDocNo: Code[20];
        CurrentBalance: Decimal;
        CurrentBalanceReverse: Decimal;
        Day: Integer;
        Week: Integer;
        Month: Integer;
        MonthText: Text[30];
        NoOfRecords: Integer;
        NoOfReversingRecords: Integer;
        LineCount: Integer;
        NoOfPostingNoSeries: Integer;
        PostingNoSeriesNo: Integer;
        DocCorrection: Boolean;
        VATEntryCreated: Boolean;
        LastFAAddCurrExchRate: Decimal;
        LastCurrencyCode: Code[10];
        CurrencyBalance: Decimal;
        Text029: Label '%1 %2 posted on %3 includes more than one customer, vendor or IC Partner.', Comment = '%1 = Document Type;%2 = Document No.;%3=Posting Date';
        Text030: Label 'You cannot enter G/L Account or Bank Account in both %1 and %2.';
        Text031: Label 'Line No. %1 does not contain a G/L Account or Bank Account. When the %2 field contains an account number, either the %3 field or the %4 field must contain a G/L Account or Bank Account.';
        RefPostingState: Option "Checking lines","Checking balance","Updating bal. lines","Posting Lines","Posting revers. lines","Updating lines";
        PreviewMode: Boolean;
        SkippedLineMsg: Label 'One or more lines has not been posted because the amount is zero.';
        ConfirmPostingAfterCurrentPeriodQst: Label 'The posting date of one or more journal lines is after the current calendar date. Do you want to continue?';
        SuppressCommit: Boolean;

    local procedure "Code"(var GenJnlLine: Record "Gen. Journal Line")
    var
        TempMarkedGenJnlLine: Record "Gen. Journal Line" temporary;
        IntegrationService: Codeunit "Integration Service";
        IntegrationManagement: Codeunit "Integration Management";
        RaiseError: Boolean;
    begin
        OnBeforeCode(GenJnlLine, PreviewMode, SuppressCommit);

        // let's force Api Enabled check.
        // this will disable integration related subscribers in case of disabled Api setup
        BindSubscription(IntegrationService);
        IntegrationManagement.ResetIntegrationActivated;

        with GenJnlLine do begin
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");

            LockTable;
            GenJnlAlloc.LockTable;

            GenJnlTemplate.Get("Journal Template Name");
            GenJnlBatch.Get("Journal Template Name", "Journal Batch Name");

            OnBeforeRaiseExceedLengthError(GenJnlBatch, RaiseError);

            if GenJnlTemplate.Recurring then begin
                TempMarkedGenJnlLine.Copy(GenJnlLine);
                CheckGenJnlLineDates(TempMarkedGenJnlLine, GenJnlLine);
                TempMarkedGenJnlLine.SetRange("Posting Date", 0D, WorkDate);
                GLSetup.Get;
            end;

            if GenJnlTemplate.Recurring then begin
                ProcessLines(TempMarkedGenJnlLine);
                Copy(TempMarkedGenJnlLine);
            end else
                ProcessLines(GenJnlLine);
        end;

        OnAfterCode(GenJnlLine, PreviewMode);
    end;

    local procedure ProcessLines(var GenJnlLine: Record "Gen. Journal Line")
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        GenJnlLineVATInfoSource: Record "Gen. Journal Line";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        ICOutboxExport: Codeunit "IC Outbox Export";
        ICLastDocNo: Code[20];
        CurrentICPartner: Code[20];
        LastLineNo: Integer;
        LastICTransactionNo: Integer;
        ICTransactionNo: Integer;
        ICLastDocType: Integer;
        ICLastDate: Date;
        VATInfoSourceLineIsInserted: Boolean;
        SkippedLine: Boolean;
        PostingAfterCurrentFiscalYearConfirmed: Boolean;
    begin
        OnBeforeProcessLines(GenJnlLine, PreviewMode, SuppressCommit);

        with GenJnlLine do begin
            if not Find('=><') then begin
                "Line No." := 0;
                if PreviewMode then
                    GenJnlPostPreview.ThrowError;
                if not SuppressCommit then
                    Commit;
                exit;
            end;

            Window.Open(PostingStateMsg);
            Window.Update(1, "Journal Batch Name");

            // Check lines
            LineCount := 0;
            StartLineNo := "Line No.";
            NoOfRecords := Count;
            GenJnlCheckLine.SetBatchMode(true);
            repeat
                LineCount := LineCount + 1;
                UpdateDialog(RefPostingState::"Checking lines", LineCount, NoOfRecords);
                CheckLine(GenJnlLine, PostingAfterCurrentFiscalYearConfirmed);
                TempGenJnlLine := GenJnlLine5;
                TempGenJnlLine.Insert;
                if Next = 0 then
                    FindFirst;
            until "Line No." = StartLineNo;
            if GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany then
                CheckICDocument(TempGenJnlLine);

            ProcessBalanceOfLines(GenJnlLine, GenJnlLineVATInfoSource, VATInfoSourceLineIsInserted, LastLineNo, CurrentICPartner);

            // Find next register no.
            GLEntry.LockTable;
            if GLEntry.FindLast then;
            FindNextGLRegisterNo;

            // Post lines
            LineCount := 0;
            LastDocNo := '';
            LastPostedDocNo := '';
            LastICTransactionNo := 0;
            TempGenJnlLine4.DeleteAll;
            NoOfReversingRecords := 0;
            FindSet(true, false);
            repeat
                ProcessICLines(CurrentICPartner, ICTransactionNo, ICLastDocNo, ICLastDate, ICLastDocType, GenJnlLine, TempGenJnlLine);
                ProcessICTransaction(LastICTransactionNo, ICTransactionNo);
                GenJnlLine3 := GenJnlLine;
                if not PostGenJournalLine(GenJnlLine3, CurrentICPartner, ICTransactionNo) then
                    SkippedLine := true;
            until Next = 0;

            if LastICTransactionNo > 0 then
                ICOutboxExport.ProcessAutoSendOutboxTransactionNo(ICTransactionNo);

            // Post reversing lines
            PostReversingLines(TempGenJnlLine4);

            OnProcessLinesOnAfterPostGenJnlLines(GenJnlLine, GLReg, GLRegNo);

            // Copy register no. and current journal batch name to general journal
            if not GLReg.FindLast or (GLReg."No." <> GLRegNo) then
                GLRegNo := 0;

            Init;
            "Line No." := GLRegNo;

            OnProcessLinesOnAfterAssignGLNegNo(GenJnlLine, GLReg, GLRegNo);

            if PreviewMode then begin
                OnBeforeThrowPreviewError(GenJnlLine, GLRegNo);
                GenJnlPostPreview.ThrowError;
            end;

            // Update/delete lines
            if GLRegNo <> 0 then
                UpdateAndDeleteLines(GenJnlLine);

            if GenJnlBatch."No. Series" <> '' then
                NoSeriesMgt.SaveNoSeries;
            if NoSeries.FindSet then
                repeat
                    Evaluate(PostingNoSeriesNo, NoSeries.Description);
                    NoSeriesMgt2[PostingNoSeriesNo].SaveNoSeries;
                until NoSeries.Next = 0;

            OnBeforeCommit(GLRegNo, GenJnlLine, GenJnlPostLine);

            if not SuppressCommit then
                Commit;
            Clear(GenJnlCheckLine);
            Clear(GenJnlPostLine);
            ClearMarks;
        end;
        UpdateAnalysisView.UpdateAll(0, true);
        GenJnlBatch.OnMoveGenJournalBatch(GLReg.RecordId);
        if not SuppressCommit then
            Commit;

        if SkippedLine and GuiAllowed then
            Message(SkippedLineMsg);

        OnAfterProcessLines(TempGenJnlLine);
    end;

    local procedure ProcessBalanceOfLines(var GenJnlLine: Record "Gen. Journal Line"; var GenJnlLineVATInfoSource: Record "Gen. Journal Line"; var VATInfoSourceLineIsInserted: Boolean; var LastLineNo: Integer; CurrentICPartner: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        BalVATPostingSetup: Record "VAT Posting Setup";
        ErrorMessage: Text;
        ForceCheckBalance: Boolean;
        IsProcessingKeySet: Boolean;
    begin
        IsProcessingKeySet := false;
        OnBeforeProcessBalanceOfLines(GenJnlLine, GenJnlBatch, GenJnlTemplate, IsProcessingKeySet);
        if not IsProcessingKeySet then
            if (GenJnlBatch."No. Series" = '') and (GenJnlBatch."Posting No. Series" = '') and GenJnlTemplate."Force Doc. Balance" then
                GenJnlLine.SetCurrentKey("Document No.");

        LineCount := 0;
        LastDate := 0D;
        LastDocType := 0;
        LastDocNo := '';
        LastFAAddCurrExchRate := 0;
        GenJnlLineTemp.Reset;
        GenJnlLineTemp.DeleteAll;
        VATEntryCreated := false;
        CurrentBalance := 0;
        CurrentBalanceReverse := 0;
        CurrencyBalance := 0;

        with GenJnlLine do begin
            FindSet(true, false);
            LastCurrencyCode := "Currency Code";

            repeat
                LineCount := LineCount + 1;
                UpdateDialog(RefPostingState::"Checking balance", LineCount, NoOfRecords);

                if not EmptyLine then begin
                    if not PreviewMode then
                        CheckDocNoBasedOnNoSeries(LastDocNo, GenJnlBatch."No. Series", NoSeriesMgt);
                    if "Posting No. Series" <> '' then
                        TestField("Posting No. Series", GenJnlBatch."Posting No. Series");
                    CheckCorrection(GenJnlLine);
                end;
                OnBeforeIfCheckBalance(GenJnlTemplate, GenJnlLine, LastDocType, LastDocNo, LastDate, ForceCheckBalance, SuppressCommit);
                if ForceCheckBalance or ("Posting Date" <> LastDate) or GenJnlTemplate."Force Doc. Balance" and
                   (("Document Type" <> LastDocType) or ("Document No." <> LastDocNo))
                then begin
                    CheckBalance(GenJnlLine);
                    CurrencyBalance := 0;
                    LastCurrencyCode := "Currency Code";
                    GenJnlLineTemp.Reset;
                    GenJnlLineTemp.DeleteAll;
                end;

                if IsNonZeroAmount(GenJnlLine) then begin
                    if LastFAAddCurrExchRate <> "FA Add.-Currency Factor" then
                        CheckAddExchRateBalance(GenJnlLine);
                    if (CurrentBalance = 0) and (CurrentICPartner = '') then begin
                        GenJnlLineTemp.Reset;
                        GenJnlLineTemp.DeleteAll;
                        if VATEntryCreated and VATInfoSourceLineIsInserted then
                            UpdateGenJnlLineWithVATInfo(GenJnlLine, GenJnlLineVATInfoSource, StartLineNo, LastLineNo);
                        VATEntryCreated := false;
                        VATInfoSourceLineIsInserted := false;
                        StartLineNo := "Line No.";
                    end;
                    if CurrentBalanceReverse = 0 then
                        StartLineNoReverse := "Line No.";
                    UpdateLineBalance;
                    OnAfterUpdateLineBalance(GenJnlLine);
                    CurrentBalance := CurrentBalance + "Balance (LCY)";
                    if "Recurring Method" >= "Recurring Method"::"RF Reversing Fixed" then
                        CurrentBalanceReverse := CurrentBalanceReverse + "Balance (LCY)";

                    UpdateCurrencyBalanceForRecurringLine(GenJnlLine);
                end;

                LastDate := "Posting Date";
                LastDocType := "Document Type";
                if not EmptyLine then
                    LastDocNo := "Document No.";
                LastFAAddCurrExchRate := "FA Add.-Currency Factor";
                if GenJnlTemplate."Force Doc. Balance" then begin
                    if not VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
                        Clear(VATPostingSetup);
                    if not BalVATPostingSetup.Get("Bal. VAT Bus. Posting Group", "Bal. VAT Prod. Posting Group") then
                        Clear(BalVATPostingSetup);
                    VATEntryCreated :=
                      VATEntryCreated or
                      (("Account Type" = "Account Type"::"G/L Account") and ("Account No." <> '') and
                       ("Gen. Posting Type" in ["Gen. Posting Type"::Purchase, "Gen. Posting Type"::Sale]) and
                       (VATPostingSetup."VAT %" <> 0)) or
                      (("Bal. Account Type" = "Bal. Account Type"::"G/L Account") and ("Bal. Account No." <> '') and
                       ("Bal. Gen. Posting Type" in ["Bal. Gen. Posting Type"::Purchase, "Bal. Gen. Posting Type"::Sale]) and
                       (BalVATPostingSetup."VAT %" <> 0));
                    if GenJnlLineTemp.IsCustVendICAdded(GenJnlLine) then begin
                        GenJnlLineVATInfoSource := GenJnlLine;
                        VATInfoSourceLineIsInserted := true;
                    end;
                    if (GenJnlLineTemp.Count > 1) and VATEntryCreated then begin
                        ErrorMessage := Text009 + Text010;
                        Error(ErrorMessage, "Document Type", "Document No.", "Posting Date");
                    end;
                    if (GenJnlLineTemp.Count > 1) and (CurrentICPartner <> '') and
                       (GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany)
                    then
                        Error(
                          Text029,
                          "Document Type", "Document No.", "Posting Date");
                    LastLineNo := "Line No.";
                end;
            until Next = 0;
            CheckBalance(GenJnlLine);
            CopyFields(GenJnlLine);
            if VATEntryCreated and VATInfoSourceLineIsInserted then
                UpdateGenJnlLineWithVATInfo(GenJnlLine, GenJnlLineVATInfoSource, StartLineNo, LastLineNo);
        end;

        OnAfterProcessBalanceOfLines(GenJnlLine);
    end;

    local procedure ProcessICLines(var CurrentICPartner: Code[20]; var ICTransactionNo: Integer; var ICLastDocNo: Code[20]; var ICLastDate: Date; var ICLastDocType: Integer; var GenJnlLine: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        HandledICInboxTrans: Record "Handled IC Inbox Trans.";
    begin
        with GenJnlLine do
            if (GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany) and not EmptyLine and
               (("Posting Date" <> ICLastDate) or ("Document Type" <> ICLastDocType) or ("Document No." <> ICLastDocNo))
            then begin
                CurrentICPartner := '';
                ICLastDate := "Posting Date";
                ICLastDocType := "Document Type";
                ICLastDocNo := "Document No.";
                TempGenJnlLine.Reset;
                TempGenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
                TempGenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                TempGenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
                TempGenJnlLine.SetRange("Posting Date", "Posting Date");
                TempGenJnlLine.SetRange("Document No.", "Document No.");
                TempGenJnlLine.SetFilter("IC Partner Code", '<>%1', '');
                if TempGenJnlLine.FindFirst and (TempGenJnlLine."IC Partner Code" <> '') then begin
                    CurrentICPartner := TempGenJnlLine."IC Partner Code";
                    if TempGenJnlLine."IC Direction" = TempGenJnlLine."IC Direction"::Outgoing then
                        ICTransactionNo := ICOutboxMgt.CreateOutboxJnlTransaction(TempGenJnlLine, false)
                    else
                        if HandledICInboxTrans.Get(
                             TempGenJnlLine."IC Partner Transaction No.", TempGenJnlLine."IC Partner Code",
                             HandledICInboxTrans."Transaction Source"::"Created by Partner", TempGenJnlLine."Document Type")
                        then begin
                            HandledICInboxTrans.LockTable;
                            HandledICInboxTrans.Status := HandledICInboxTrans.Status::Posted;
                            HandledICInboxTrans.Modify;
                        end
                end
            end;
    end;

    local procedure ProcessICTransaction(var LastICTransactionNo: Integer; ICTransactionNo: Integer)
    var
        ICOutboxExport: Codeunit "IC Outbox Export";
    begin
        if LastICTransactionNo = 0 then
            LastICTransactionNo := ICTransactionNo
        else
            if LastICTransactionNo <> ICTransactionNo then begin
                ICOutboxExport.ProcessAutoSendOutboxTransactionNo(LastICTransactionNo);
                LastICTransactionNo := ICTransactionNo;
            end;
    end;

    local procedure CheckBalance(var GenJnlLine: Record "Gen. Journal Line")
    begin
        OnBeforeCheckBalance(
          GenJnlTemplate, GenJnlLine, CurrentBalance, CurrentBalanceReverse, CurrencyBalance,
          StartLineNo, StartLineNoReverse, LastDocType, LastDocNo, LastDate, LastCurrencyCode, SuppressCommit);

        with GenJnlLine do begin
            if CurrentBalance <> 0 then begin
                Get("Journal Template Name", "Journal Batch Name", StartLineNo);
                if GenJnlTemplate."Force Doc. Balance" then
                    Error(
                      Text012 +
                      Text013,
                      CurrentBalance, LastDocNo, FieldCaption("Posting Date"), FieldCaption("Document Type"),
                      FieldCaption("Document No."), FieldCaption(Amount));
                Error(
                  Text014 +
                  Text015,
                  LastDate, CurrentBalance, FieldCaption("Posting Date"), FieldCaption(Amount));
            end;
            if CurrentBalanceReverse <> 0 then begin
                Get("Journal Template Name", "Journal Batch Name", StartLineNoReverse);
                if GenJnlTemplate."Force Doc. Balance" then
                    Error(
                      Text016 +
                      Text017,
                      CurrentBalanceReverse, LastDocNo, FieldCaption("Recurring Method"), FieldCaption("Document No."));
                Error(
                  Text018 +
                  Text017,
                  LastDate, CurrentBalanceReverse, FieldCaption("Recurring Method"), FieldCaption("Posting Date"));
            end;
            if (LastCurrencyCode <> '') and (CurrencyBalance <> 0) then begin
                Get("Journal Template Name", "Journal Batch Name", StartLineNo);
                if GenJnlTemplate."Force Doc. Balance" then
                    Error(
                      Text026 +
                      Text013,
                      CurrencyBalance, LastDocNo, FieldCaption("Posting Date"), FieldCaption("Document Type"),
                      FieldCaption("Document No."), FieldCaption(Amount),
                      LastCurrencyCode);
                Error(
                  Text027 +
                  Text015,
                  LastDate, CurrencyBalance, FieldCaption("Posting Date"), FieldCaption(Amount), LastCurrencyCode);
            end;
        end;
    end;

    local procedure CheckCorrection(GenJournalLine: Record "Gen. Journal Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckCorrection(GenJournalLine, IsHandled);
        if IsHandled then
            exit;

        with GenJournalLine do
            if ("Posting Date" <> LastDate) or ("Document Type" <> LastDocType) or ("Document No." <> LastDocNo) then begin
                if Correction then
                    GenJnlTemplate.TestField("Force Doc. Balance", true);
                DocCorrection := Correction;
            end else
                if Correction <> DocCorrection then
                    FieldError(Correction, Text008);
    end;

    local procedure CheckAddExchRateBalance(GenJnlLine: Record "Gen. Journal Line")
    begin
        with GenJnlLine do
            if CurrentBalance <> 0 then
                Error(
                  Text019 +
                  Text020,
                  LastDocNo, FieldCaption("FA Add.-Currency Factor"), FieldCaption("Document No."));
    end;

    local procedure CheckRecurringLine(var GenJnlLine2: Record "Gen. Journal Line")
    var
        DummyDateFormula: DateFormula;
    begin
        with GenJnlLine2 do
            if "Account No." <> '' then
                if GenJnlTemplate.Recurring then begin
                    TestField("Recurring Method");
                    TestField("Recurring Frequency");
                    if "Bal. Account No." <> '' then
                        FieldError("Bal. Account No.", Text021);
                    case "Recurring Method" of
                        "Recurring Method"::"V  Variable", "Recurring Method"::"RV Reversing Variable",
                      "Recurring Method"::"F  Fixed", "Recurring Method"::"RF Reversing Fixed":
                            if not "Allow Zero-Amount Posting" then
                                TestField(Amount);
                        "Recurring Method"::"B  Balance", "Recurring Method"::"RB Reversing Balance":
                            TestField(Amount, 0);
                    end;
                end else begin
                    TestField("Recurring Method", 0);
                    TestField("Recurring Frequency", DummyDateFormula);
                end;
    end;

    local procedure UpdateRecurringAmt(var GenJnlLine2: Record "Gen. Journal Line"): Boolean
    begin
        with GenJnlLine2 do
            if ("Account No." <> '') and
               ("Recurring Method" in
                ["Recurring Method"::"B  Balance", "Recurring Method"::"RB Reversing Balance"])
            then begin
                GLEntry.LockTable;
                if "Account Type" = "Account Type"::"G/L Account" then begin
                    GLAcc."No." := "Account No.";
                    GLAcc.SetRange("Date Filter", 0D, "Posting Date");
                    if GLSetup."Additional Reporting Currency" <> '' then begin
                        "Source Currency Code" := GLSetup."Additional Reporting Currency";
                        GLAcc.CalcFields("Additional-Currency Net Change");
                        "Source Currency Amount" := -GLAcc."Additional-Currency Net Change";
                        GenJnlAlloc.UpdateAllocationsAddCurr(GenJnlLine2, "Source Currency Amount");
                    end;
                    GLAcc.CalcFields("Net Change");
                    Validate(Amount, -GLAcc."Net Change");
                    exit(true);
                end;
                Error(Text022);
            end;
        exit(false);
    end;

    local procedure CheckAllocations(var GenJnlLine2: Record "Gen. Journal Line")
    begin
        with GenJnlLine2 do
            if "Account No." <> '' then begin
                if "Recurring Method" in
                   ["Recurring Method"::"B  Balance",
                    "Recurring Method"::"RB Reversing Balance"]
                then begin
                    GenJnlAlloc.Reset;
                    GenJnlAlloc.SetRange("Journal Template Name", "Journal Template Name");
                    GenJnlAlloc.SetRange("Journal Batch Name", "Journal Batch Name");
                    GenJnlAlloc.SetRange("Journal Line No.", "Line No.");
                    if GenJnlAlloc.IsEmpty then
                        Error(
                          Text028);
                end;

                GenJnlAlloc.Reset;
                GenJnlAlloc.SetRange("Journal Template Name", "Journal Template Name");
                GenJnlAlloc.SetRange("Journal Batch Name", "Journal Batch Name");
                GenJnlAlloc.SetRange("Journal Line No.", "Line No.");
                GenJnlAlloc.SetFilter(Amount, '<>0');
                if not GenJnlAlloc.IsEmpty then begin
                    if not GenJnlTemplate.Recurring then
                        Error(Text023);
                    GenJnlAlloc.SetRange("Account No.", '');
                    if GenJnlAlloc.FindFirst then
                        GenJnlAlloc.TestField("Account No.");
                end;
            end;
    end;

    local procedure MakeRecurringTexts(var GenJnlLine2: Record "Gen. Journal Line")
    begin
        with GenJnlLine2 do
            if ("Account No." <> '') and ("Recurring Method" <> 0) then begin
                Day := Date2DMY("Posting Date", 1);
                Week := Date2DWY("Posting Date", 2);
                Month := Date2DMY("Posting Date", 2);
                MonthText := Format("Posting Date", 0, Text024);
                AccountingPeriod.SetRange("Starting Date", 0D, "Posting Date");
                if not AccountingPeriod.FindLast then
                    AccountingPeriod.Name := '';
                "Document No." :=
                  DelChr(
                    PadStr(
                      StrSubstNo("Document No.", Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MaxStrLen("Document No.")),
                    '>');
                Description :=
                  DelChr(
                    PadStr(
                      StrSubstNo(Description, Day, Week, Month, MonthText, AccountingPeriod.Name),
                      MaxStrLen(Description)),
                    '>');
                OnAfterMakeRecurringTexts(GenJnlLine2, AccountingPeriod, Day, Week, Month, MonthText);
            end;
    end;

    local procedure PostAllocations(var AllocateGenJnlLine: Record "Gen. Journal Line"; Reversing: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforePostAllocations(AllocateGenJnlLine, Reversing, IsHandled);
        if IsHandled then
            exit;

        with AllocateGenJnlLine do
            if "Account No." <> '' then begin
                GenJnlAlloc.Reset;
                GenJnlAlloc.SetRange("Journal Template Name", "Journal Template Name");
                GenJnlAlloc.SetRange("Journal Batch Name", "Journal Batch Name");
                GenJnlAlloc.SetRange("Journal Line No.", "Line No.");
                GenJnlAlloc.SetFilter("Account No.", '<>%1', '');
                if GenJnlAlloc.FindSet(true, false) then begin
                    GenJnlLine2.Init;
                    GenJnlLine2."Account Type" := GenJnlLine2."Account Type"::"G/L Account";
                    GenJnlLine2."Posting Date" := "Posting Date";
                    GenJnlLine2."Document Type" := "Document Type";
                    GenJnlLine2."Document No." := "Document No.";
                    GenJnlLine2.Description := Description;
                    GenJnlLine2."Source Code" := "Source Code";
                    GenJnlLine2."Journal Batch Name" := "Journal Batch Name";
                    GenJnlLine2."Line No." := "Line No.";
                    GenJnlLine2."Reason Code" := "Reason Code";
                    GenJnlLine2.Correction := Correction;
                    GenJnlLine2."Recurring Method" := "Recurring Method";
                    if "Account Type" in ["Account Type"::Customer, "Account Type"::Vendor] then begin
                        GenJnlLine2."Bill-to/Pay-to No." := "Bill-to/Pay-to No.";
                        GenJnlLine2."Ship-to/Order Address Code" := "Ship-to/Order Address Code";
                    end;
                    OnPostAllocationsOnBeforeCopyFromGenJnlAlloc(GenJnlLine2, AllocateGenJnlLine, Reversing);
                    repeat
                        GenJnlLine2.CopyFromGenJnlAllocation(GenJnlAlloc);
                        GenJnlLine2."Shortcut Dimension 1 Code" := GenJnlAlloc."Shortcut Dimension 1 Code";
                        GenJnlLine2."Shortcut Dimension 2 Code" := GenJnlAlloc."Shortcut Dimension 2 Code";
                        GenJnlLine2."Dimension Set ID" := GenJnlAlloc."Dimension Set ID";
                        GenJnlLine2."Deductible %" := GenJnlAlloc."Deductible %";
                        GenJnlLine2."Operation Occurred Date" := "Operation Occurred Date";
                        GenJnlLine2."Allow Zero-Amount Posting" := true;
                        PrepareGenJnlLineAddCurr(GenJnlLine2);
                        if not Reversing then begin
                            OnPostAllocationsOnBeforePostNotReversingLine(GenJnlLine2, GenJnlPostLine);
                            GenJnlPostLine.RunWithCheck(GenJnlLine2);
                            if "Recurring Method" in
                               ["Recurring Method"::"V  Variable", "Recurring Method"::"B  Balance"]
                            then begin
                                GenJnlAlloc.Amount := 0;
                                GenJnlAlloc."Additional-Currency Amount" := 0;
                                GenJnlAlloc.Modify;
                            end;
                        end else begin
                            MultiplyAmounts(GenJnlLine2, -1);
                            GenJnlLine2."Reversing Entry" := true;
                            OnPostAllocationsOnBeforePostReversingLine(GenJnlLine2, GenJnlPostLine);
                            GenJnlPostLine.RunWithCheck(GenJnlLine2);
                            if "Recurring Method" in
                               ["Recurring Method"::"RV Reversing Variable",
                                "Recurring Method"::"RB Reversing Balance"]
                            then begin
                                GenJnlAlloc.Amount := 0;
                                GenJnlAlloc."Additional-Currency Amount" := 0;
                                GenJnlAlloc.Modify;
                            end;
                        end;
                    until GenJnlAlloc.Next = 0;
                end;
            end;

        OnAfterPostAllocations(AllocateGenJnlLine, Reversing, SuppressCommit);
    end;

    local procedure MultiplyAmounts(var GenJnlLine2: Record "Gen. Journal Line"; Factor: Decimal)
    begin
        with GenJnlLine2 do
            if "Account No." <> '' then begin
                Amount := Amount * Factor;
                "Debit Amount" := "Debit Amount" * Factor;
                "Credit Amount" := "Credit Amount" * Factor;
                "Amount (LCY)" := "Amount (LCY)" * Factor;
                "Balance (LCY)" := "Balance (LCY)" * Factor;
                "Sales/Purch. (LCY)" := "Sales/Purch. (LCY)" * Factor;
                "Profit (LCY)" := "Profit (LCY)" * Factor;
                "Inv. Discount (LCY)" := "Inv. Discount (LCY)" * Factor;
                Quantity := Quantity * Factor;
                "VAT Amount" := "VAT Amount" * Factor;
                "VAT Base Amount" := "VAT Base Amount" * Factor;
                "VAT Amount (LCY)" := "VAT Amount (LCY)" * Factor;
                "VAT Base Amount (LCY)" := "VAT Base Amount (LCY)" * Factor;
                "Source Currency Amount" := "Source Currency Amount" * Factor;
                if "Job No." <> '' then begin
                    "Job Quantity" := "Job Quantity" * Factor;
                    "Job Total Cost (LCY)" := "Job Total Cost (LCY)" * Factor;
                    "Job Total Price (LCY)" := "Job Total Price (LCY)" * Factor;
                    "Job Line Amount (LCY)" := "Job Line Amount (LCY)" * Factor;
                    "Job Total Cost" := "Job Total Cost" * Factor;
                    "Job Total Price" := "Job Total Price" * Factor;
                    "Job Line Amount" := "Job Line Amount" * Factor;
                    "Job Line Discount Amount" := "Job Line Discount Amount" * Factor;
                    "Job Line Disc. Amount (LCY)" := "Job Line Disc. Amount (LCY)" * Factor;
                end;
            end;

        OnAfterMultiplyAmounts(GenJnlLine2, Factor, SuppressCommit);
    end;

    local procedure CheckDocumentNo(var GenJnlLine2: Record "Gen. Journal Line")
    begin
        with GenJnlLine2 do
            if "Posting No. Series" = '' then
                "Posting No. Series" := GenJnlBatch."No. Series"
            else
                if not EmptyLine then
                    if "Document No." = LastDocNo then
                        "Document No." := LastPostedDocNo
                    else begin
                        if not NoSeries.Get("Posting No. Series") then begin
                            NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
                            if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
                                Error(
                                  Text025,
                                  ArrayLen(NoSeriesMgt2));
                            NoSeries.Code := "Posting No. Series";
                            NoSeries.Description := Format(NoOfPostingNoSeries);
                            NoSeries.Insert;
                        end;
                        LastDocNo := "Document No.";
                        Evaluate(PostingNoSeriesNo, NoSeries.Description);
                        "Document No." :=
                          NoSeriesMgt2[PostingNoSeriesNo].GetNextNo("Posting No. Series", "Posting Date", true);
                        LastPostedDocNo := "Document No.";
                    end;
    end;

    local procedure PrepareGenJnlLineAddCurr(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if (GLSetup."Additional Reporting Currency" <> '') and
           (GenJnlLine."Recurring Method" in
            [GenJnlLine."Recurring Method"::"B  Balance",
             GenJnlLine."Recurring Method"::"RB Reversing Balance"])
        then begin
            GenJnlLine."Source Currency Code" := GLSetup."Additional Reporting Currency";
            if (GenJnlLine.Amount = 0) and
               (GenJnlLine."Source Currency Amount" <> 0)
            then begin
                GenJnlLine."Additional-Currency Posting" :=
                  GenJnlLine."Additional-Currency Posting"::"Additional-Currency Amount Only";
                GenJnlLine.Amount := GenJnlLine."Source Currency Amount";
                GenJnlLine."Source Currency Amount" := 0;
            end;
        end;
    end;

    local procedure CopyFields(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine4: Record "Gen. Journal Line";
        GenJnlLine6: Record "Gen. Journal Line";
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        JnlLineTotalQty: Integer;
        RefPostingSubState: Option "Check account","Check bal. account","Update lines";
    begin
        GenJnlLine6.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
        GenJnlLine4.FilterGroup(2);
        GenJnlLine4.Copy(GenJnlLine);
        GenJnlLine4.FilterGroup(0);
        GenJnlLine6.FilterGroup(2);
        GenJnlLine6.Copy(GenJnlLine);
        GenJnlLine6.FilterGroup(0);
        GenJnlLine6.SetFilter(
          "Account Type", '<>%1&<>%2', GenJnlLine6."Account Type"::Customer, GenJnlLine6."Account Type"::Vendor);
        GenJnlLine6.SetFilter(
          "Bal. Account Type", '<>%1&<>%2', GenJnlLine6."Bal. Account Type"::Customer, GenJnlLine6."Bal. Account Type"::Vendor);
        GenJnlLine4.SetFilter(
          "Account Type", '%1|%2', GenJnlLine4."Account Type"::Customer, GenJnlLine4."Account Type"::Vendor);
        GenJnlLine4.SetRange("Bal. Account No.", '');
        CheckAndCopyBalancingData(GenJnlLine4, GenJnlLine6, TempGenJnlLine, false);

        GenJnlLine4.SetRange("Account Type");
        GenJnlLine4.SetRange("Bal. Account No.");
        GenJnlLine4.SetFilter(
          "Bal. Account Type", '%1|%2', GenJnlLine4."Bal. Account Type"::Customer, GenJnlLine4."Bal. Account Type"::Vendor);
        GenJnlLine4.SetRange("Account No.", '');
        CheckAndCopyBalancingData(GenJnlLine4, GenJnlLine6, TempGenJnlLine, true);

        JnlLineTotalQty := TempGenJnlLine.Count;
        LineCount := 0;
        if TempGenJnlLine.FindSet then
            repeat
                LineCount := LineCount + 1;
                UpdateDialogUpdateBalLines(RefPostingSubState::"Update lines", LineCount, JnlLineTotalQty);
                GenJnlLine4.Get(TempGenJnlLine."Journal Template Name", TempGenJnlLine."Journal Batch Name", TempGenJnlLine."Line No.");
                CopyGenJnlLineBalancingData(GenJnlLine4, TempGenJnlLine);
                GenJnlLine4.Modify;
            until TempGenJnlLine.Next = 0;
    end;

    local procedure CheckICDocument(var TempGenJnlLine1: Record "Gen. Journal Line" temporary)
    var
        TempGenJnlLine2: Record "Gen. Journal Line" temporary;
        CurrentICPartner: Code[20];
    begin
        with TempGenJnlLine1 do begin
            SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            Find('-');
            repeat
                if ("Posting Date" <> LastDate) or ("Document Type" <> LastDocType) or ("Document No." <> LastDocNo) then begin
                    TempGenJnlLine2 := TempGenJnlLine1;
                    SetRange("Posting Date", "Posting Date");
                    SetRange("Document No.", "Document No.");
                    SetFilter("IC Partner Code", '<>%1', '');
                    if Find('-') then
                        CurrentICPartner := "IC Partner Code"
                    else
                        CurrentICPartner := '';
                    SetRange("Posting Date");
                    SetRange("Document No.");
                    SetRange("IC Partner Code");
                    LastDate := "Posting Date";
                    LastDocType := "Document Type";
                    LastDocNo := "Document No.";
                    TempGenJnlLine1 := TempGenJnlLine2;
                end;
                if (CurrentICPartner <> '') and ("IC Direction" = "IC Direction"::Outgoing) then begin
                    if ("Account Type" in ["Account Type"::"G/L Account", "Account Type"::"Bank Account"]) and
                       ("Bal. Account Type" in ["Bal. Account Type"::"G/L Account", "Account Type"::"Bank Account"]) and
                       ("Account No." <> '') and
                       ("Bal. Account No." <> '')
                    then
                        Error(Text030, FieldCaption("Account No."), FieldCaption("Bal. Account No."));
                    if (("Account Type" in ["Account Type"::"G/L Account", "Account Type"::"Bank Account"]) and ("Account No." <> '')) xor
                       (("Bal. Account Type" in ["Bal. Account Type"::"G/L Account", "Account Type"::"Bank Account"]) and
                        ("Bal. Account No." <> ''))
                    then
                        TestField("IC Partner G/L Acc. No.")
                    else
                        if "IC Partner G/L Acc. No." <> '' then
                            Error(Text031,
                              "Line No.", FieldCaption("IC Partner G/L Acc. No."), FieldCaption("Account No."),
                              FieldCaption("Bal. Account No."));
                end else
                    TestField("IC Partner G/L Acc. No.", '');
            until Next = 0;
        end;
    end;

    local procedure UpdateIncomingDocument(var GenJnlLine: Record "Gen. Journal Line")
    var
        IncomingDocument: Record "Incoming Document";
    begin
        OnBeforeUpdateIncomingDocument(GenJnlLine);
        IncomingDocument.UpdateIncomingDocumentFromPosting(
          GenJnlLine."Incoming Document Entry No.", GenJnlLine."Posting Date", GenJnlLine."Document No.");
    end;

    local procedure CopyGenJnlLineBalancingData(var GenJnlLineTo: Record "Gen. Journal Line"; var GenJnlLineFrom: Record "Gen. Journal Line")
    begin
        GenJnlLineTo."Bill-to/Pay-to No." := GenJnlLineFrom."Bill-to/Pay-to No.";
        GenJnlLineTo."Ship-to/Order Address Code" := GenJnlLineFrom."Ship-to/Order Address Code";
        GenJnlLineTo."VAT Registration No." := GenJnlLineFrom."VAT Registration No.";
        GenJnlLineTo."Country/Region Code" := GenJnlLineFrom."Country/Region Code";
    end;

    local procedure CheckGenPostingType(GenJnlLine6: Record "Gen. Journal Line"; AccountType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner")
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckGenPostingType(GenJnlLine6, AccountType, IsHandled);
        if IsHandled then
            exit;

        if (AccountType = AccountType::Customer) and
           (GenJnlLine6."Gen. Posting Type" = GenJnlLine6."Gen. Posting Type"::Purchase) or
           (AccountType = AccountType::Vendor) and
           (GenJnlLine6."Gen. Posting Type" = GenJnlLine6."Gen. Posting Type"::Sale)
        then
            GenJnlLine6.FieldError("Gen. Posting Type");
        if (AccountType = AccountType::Customer) and
           (GenJnlLine6."Bal. Gen. Posting Type" = GenJnlLine6."Bal. Gen. Posting Type"::Purchase) or
           (AccountType = AccountType::Vendor) and
           (GenJnlLine6."Bal. Gen. Posting Type" = GenJnlLine6."Bal. Gen. Posting Type"::Sale)
        then
            GenJnlLine6.FieldError("Bal. Gen. Posting Type");
    end;

    local procedure CheckAndCopyBalancingData(var GenJnlLine4: Record "Gen. Journal Line"; var GenJnlLine6: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary; CheckBalAcount: Boolean)
    var
        TempGenJournalLineHistory: Record "Gen. Journal Line" temporary;
        AccountType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner";
        CheckAmount: Decimal;
        JnlLineTotalQty: Integer;
        RefPostingSubState: Option "Check account","Check bal. account","Update lines";
        LinesFound: Boolean;
    begin
        JnlLineTotalQty := GenJnlLine4.Count;
        LineCount := 0;
        if CheckBalAcount then
            RefPostingSubState := RefPostingSubState::"Check bal. account"
        else
            RefPostingSubState := RefPostingSubState::"Check account";
        if GenJnlLine4.FindSet then
            repeat
                LineCount := LineCount + 1;
                UpdateDialogUpdateBalLines(RefPostingSubState, LineCount, JnlLineTotalQty);
                TempGenJournalLineHistory.SetRange("Posting Date", GenJnlLine4."Posting Date");
                TempGenJournalLineHistory.SetRange("Document No.", GenJnlLine4."Document No.");
                if TempGenJournalLineHistory.IsEmpty then begin
                    TempGenJournalLineHistory := GenJnlLine4;
                    TempGenJournalLineHistory.Insert;
                    GenJnlLine6.SetRange("Posting Date", GenJnlLine4."Posting Date");
                    GenJnlLine6.SetRange("Document No.", GenJnlLine4."Document No.");
                    LinesFound := GenJnlLine6.FindSet;
                end;
                if LinesFound then begin
                    AccountType := GetPostingTypeFilter(GenJnlLine4, CheckBalAcount);
                    CheckAmount := 0;
                    repeat
                        if (GenJnlLine6."Account No." = '') <> (GenJnlLine6."Bal. Account No." = '') then begin
                            CheckGenPostingType(GenJnlLine6, AccountType);
                            if GenJnlLine6."Bill-to/Pay-to No." = '' then begin
                                TempGenJnlLine := GenJnlLine6;
                                CopyGenJnlLineBalancingData(TempGenJnlLine, GenJnlLine4);
                                if TempGenJnlLine.Insert then;
                            end;
                            CheckAmount := CheckAmount + GenJnlLine6.Amount;
                        end;
                        LinesFound := (GenJnlLine6.Next <> 0);
                    until not LinesFound or (-GenJnlLine4.Amount = CheckAmount);
                end;
            until GenJnlLine4.Next = 0;
    end;

    local procedure UpdateGenJnlLineWithVATInfo(var GenJournalLine: Record "Gen. Journal Line"; GenJournalLineVATInfoSource: Record "Gen. Journal Line"; StartLineNo: Integer; LastLineNo: Integer)
    var
        GenJournalLineCopy: Record "Gen. Journal Line";
        Finish: Boolean;
        OldLineNo: Integer;
    begin
        OldLineNo := GenJournalLine."Line No.";
        with GenJournalLine do begin
            "Line No." := StartLineNo;
            Finish := false;
            if Get("Journal Template Name", "Journal Batch Name", "Line No.") then
                repeat
                    if "Line No." <> GenJournalLineVATInfoSource."Line No." then begin
                        "Bill-to/Pay-to No." := GenJournalLineVATInfoSource."Bill-to/Pay-to No.";
                        "Country/Region Code" := GenJournalLineVATInfoSource."Country/Region Code";
                        "VAT Registration No." := GenJournalLineVATInfoSource."VAT Registration No.";
                        Modify;
                        if IsTemporary then begin
                            GenJournalLineCopy.Get("Journal Template Name", "Journal Batch Name", "Line No.");
                            GenJournalLineCopy."Bill-to/Pay-to No." := "Bill-to/Pay-to No.";
                            GenJournalLineCopy."Country/Region Code" := "Country/Region Code";
                            GenJournalLineCopy."VAT Registration No." := "VAT Registration No.";
                            GenJournalLineCopy.Modify;
                        end;
                    end;
                    Finish := "Line No." = LastLineNo;
                until (Next = 0) or Finish;

            if Get("Journal Template Name", "Journal Batch Name", OldLineNo) then;
        end;
    end;

    local procedure GetPostingTypeFilter(var GenJnlLine4: Record "Gen. Journal Line"; CheckBalAcount: Boolean): Integer
    begin
        if CheckBalAcount then
            exit(GenJnlLine4."Bal. Account Type");
        exit(GenJnlLine4."Account Type");
    end;

    local procedure UpdateDialog(PostingState: Integer; LineNo: Integer; TotalLinesQty: Integer)
    begin
        UpdatePostingState(PostingState, LineNo);
        Window.Update(2, GetProgressBarValue(PostingState, LineNo, TotalLinesQty));
    end;

    local procedure UpdateDialogUpdateBalLines(PostingSubState: Integer; LineNo: Integer; TotalLinesQty: Integer)
    begin
        UpdatePostingState(RefPostingState::"Updating bal. lines", LineNo);
        Window.Update(
          2,
          GetProgressBarUpdateBalLinesValue(
            CalcProgressPercent(PostingSubState, 3, LineCount, TotalLinesQty)));
    end;

    local procedure UpdatePostingState(PostingState: Integer; LineNo: Integer)
    begin
        Window.Update(3, StrSubstNo('%1 (%2)', GetPostingStateMsg(PostingState), LineNo));
    end;

    local procedure UpdateCurrencyBalanceForRecurringLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        with GenJnlLine do begin
            if "Recurring Method" <> "Recurring Method"::" " then
                CalcFields("Allocated Amt. (LCY)");
            if ("Recurring Method" = "Recurring Method"::" ") or ("Amount (LCY)" <> -"Allocated Amt. (LCY)") then
                if "Currency Code" <> LastCurrencyCode then
                    LastCurrencyCode := ''
                else
                    if ("Currency Code" <> '') and (("Account No." = '') xor ("Bal. Account No." = '')) then
                        if "Account No." <> '' then
                            CurrencyBalance := CurrencyBalance + Amount
                        else
                            CurrencyBalance := CurrencyBalance - Amount;
        end;
    end;

    local procedure GetPostingStateMsg(PostingState: Integer): Text
    begin
        case PostingState of
            RefPostingState::"Checking lines":
                exit(CheckingLinesMsg);
            RefPostingState::"Checking balance":
                exit(CheckingBalanceMsg);
            RefPostingState::"Updating bal. lines":
                exit(UpdatingBalLinesMsg);
            RefPostingState::"Posting Lines":
                exit(PostingLinesMsg);
            RefPostingState::"Posting revers. lines":
                exit(PostingReversLinesMsg);
            RefPostingState::"Updating lines":
                exit(UpdatingLinesMsg);
        end;
    end;

    local procedure GetProgressBarValue(PostingState: Integer; LineNo: Integer; TotalLinesQty: Integer): Integer
    begin
        exit(Round(100 * CalcProgressPercent(PostingState, GetNumberOfPostingStages, LineNo, TotalLinesQty), 1));
    end;

    local procedure GetProgressBarUpdateBalLinesValue(PostingStatePercent: Decimal): Integer
    begin
        exit(Round((RefPostingState::"Updating bal. lines" * 100 + PostingStatePercent) / GetNumberOfPostingStages * 100, 1));
    end;

    local procedure CalcProgressPercent(PostingState: Integer; NumberOfPostingStates: Integer; LineNo: Integer; TotalLinesQty: Integer): Decimal
    begin
        exit(100 / NumberOfPostingStates * (PostingState + LineNo / TotalLinesQty));
    end;

    local procedure GetNumberOfPostingStages(): Integer
    begin
        if GenJnlTemplate.Recurring then
            exit(6);

        exit(4);
    end;

    local procedure FindNextGLRegisterNo()
    begin
        GLReg.LockTable;
        if GLReg.FindLast then
            GLRegNo := GLReg."No." + 1
        else
            GLRegNo := 1;
    end;

    local procedure CheckGenJnlLineDates(var MarkedGenJnlLine: Record "Gen. Journal Line"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        with GenJournalLine do begin
            if not Find then
                FindSet;
            SetRange("Posting Date", 0D, WorkDate);
            if FindSet then begin
                StartLineNo := "Line No.";
                repeat
                    if IsNotExpired(GenJournalLine) and IsPostingDateAllowed(GenJournalLine) then begin
                        MarkedGenJnlLine := GenJournalLine;
                        MarkedGenJnlLine.Insert;
                    end;
                    if Next = 0 then
                        FindFirst;
                until "Line No." = StartLineNo
            end;
            MarkedGenJnlLine := GenJournalLine;
        end;
    end;

    local procedure IsNotExpired(GenJournalLine: Record "Gen. Journal Line"): Boolean
    begin
        exit((GenJournalLine."Expiration Date" = 0D) or (GenJournalLine."Expiration Date" >= GenJournalLine."Posting Date"));
    end;

    local procedure IsPostingDateAllowed(GenJournalLine: Record "Gen. Journal Line"): Boolean
    begin
        exit(not GenJnlCheckLine.DateNotAllowed(GenJournalLine."Posting Date"));
    end;

    procedure SetPreviewMode(NewPreviewMode: Boolean)
    begin
        PreviewMode := NewPreviewMode;
    end;

    local procedure PostReversingLines(var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        GenJournalLine1: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        LineCount := 0;
        LastDocNo := '';
        LastPostedDocNo := '';
        if TempGenJnlLine.Find('-') then
            repeat
                GenJournalLine1 := TempGenJnlLine;
                with GenJournalLine1 do begin
                    LineCount := LineCount + 1;
                    UpdateDialog(RefPostingState::"Posting revers. lines", LineCount, NoOfReversingRecords);
                    CheckDocumentNo(GenJournalLine1);
                    GenJournalLine2.Copy(GenJournalLine1);
                    PrepareGenJnlLineAddCurr(GenJournalLine2);
                    OnPostReversingLinesOnBeforeGenJnlPostLine(GenJournalLine2, GenJnlPostLine);
                    GenJnlPostLine.RunWithCheck(GenJournalLine2);
                    PostAllocations(GenJournalLine1, true);
                end;
            until TempGenJnlLine.Next = 0;

        OnAfterPostReversingLines(TempGenJnlLine, PreviewMode);
    end;

    local procedure UpdateAndDeleteLines(var GenJnlLine: Record "Gen. Journal Line")
    var
        TempGenJnlLine2: Record "Gen. Journal Line" temporary;
        OldVATAmount: Decimal;
        OldVATPct: Decimal;
    begin
        OnBeforeUpdateAndDeleteLines(GenJnlLine, SuppressCommit);

        ClearDataExchEntries(GenJnlLine);
        if GenJnlTemplate.Recurring then begin
            // Recurring journal
            LineCount := 0;
            GenJnlLine2.Copy(GenJnlLine);
            GenJnlLine2.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
            GenJnlLine2.FindSet(true, false);
            repeat
                LineCount := LineCount + 1;
                UpdateDialog(RefPostingState::"Updating lines", LineCount, NoOfRecords);
                OldVATAmount := GenJnlLine2."VAT Amount";
                OldVATPct := GenJnlLine2."VAT %";
                if GenJnlLine2."Posting Date" <> 0D then
                    GenJnlLine2.Validate(
                      "Posting Date", CalcDate(GenJnlLine2."Recurring Frequency", GenJnlLine2."Posting Date"));
                if not
                   (GenJnlLine2."Recurring Method" in
                    [GenJnlLine2."Recurring Method"::"F  Fixed",
                     GenJnlLine2."Recurring Method"::"RF Reversing Fixed"])
                then
                    MultiplyAmounts(GenJnlLine2, 0)
                else
                    if (GenJnlLine2."VAT %" = OldVATPct) and (GenJnlLine2."VAT Amount" <> OldVATAmount) then
                        GenJnlLine2.Validate("VAT Amount", OldVATAmount);
                GenJnlLine2.Modify;
            until GenJnlLine2.Next = 0;
        end else begin
            // Not a recurring journal
            GenJnlLine2.Copy(GenJnlLine);
            GenJnlLine2.SetFilter("Account No.", '<>%1', '');
            if GenJnlLine2.FindLast then; // Remember the last line
            GenJnlLine3.Copy(GenJnlLine);
            GenJnlLine3.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Line No.");
            GenJnlLine3.DeleteAll;
            GenJnlLine3.Reset;
            GenJnlLine3.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
            GenJnlLine3.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
            if GenJnlTemplate."Increment Batch Name" then
                if not GenJnlLine3.FindLast then
                    if IncStr(GenJnlLine."Journal Batch Name") <> '' then begin
                        GenJnlBatch.Delete;
                        if GenJnlTemplate.Type = GenJnlTemplate.Type::Assets then
                            FAJnlSetup.IncGenJnlBatchName(GenJnlBatch);
                        GenJnlBatch.Name := IncStr(GenJnlLine."Journal Batch Name");
                        if GenJnlBatch.Insert then;
                        GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
                        OnAfterIncrementBatchName(GenJnlBatch, GenJnlLine2."Journal Batch Name");
                    end;

            GenJnlLine3.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
            if (GenJnlBatch."No. Series" = '') and not GenJnlLine3.FindLast then begin
                GenJnlLine3.Init;
                GenJnlLine3."Journal Template Name" := GenJnlLine."Journal Template Name";
                GenJnlLine3."Journal Batch Name" := GenJnlLine."Journal Batch Name";
                GenJnlLine3."Line No." := 10000;
                GenJnlLine3.Insert;
                TempGenJnlLine2 := GenJnlLine2;
                TempGenJnlLine2."Balance (LCY)" := 0;
                GenJnlLine3.SetUpNewLine(TempGenJnlLine2, 0, true);
                GenJnlLine3.Modify;
            end;
        end;
    end;

    [Scope('OnPrem')]
    procedure Preview(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        PreviewMode := true;
        GenJnlLine.Copy(GenJournalLine);
        GenJnlLine.SetAutoCalcFields;
        Code(GenJnlLine);
    end;

    local procedure CheckRestrictions(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if not PreviewMode then
            GenJournalLine.OnCheckGenJournalLinePostRestrictions;
    end;

    local procedure ClearDataExchEntries(var PassedGenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Copy(PassedGenJnlLine);
        if GenJnlLine.FindSet then
            repeat
                GenJnlLine.ClearDataExchangeEntries(true);
            until GenJnlLine.Next = 0;
    end;

    local procedure PostGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; CurrentICPartner: Code[20]; ICTransactionNo: Integer): Boolean
    var
        TmpWithholdingContribution: Record "Tmp Withholding Contribution";
        WithholdingContribution: Codeunit "Withholding - Contribution";
        IsPosted: Boolean;
    begin
        with GenJournalLine do begin
            if NeedCheckZeroAmount and (Amount = 0) and IsRecurring then
                exit(false);

            LineCount := LineCount + 1;
            if CurrentICPartner <> '' then
                "IC Partner Code" := CurrentICPartner;
            UpdateDialog(RefPostingState::"Posting Lines", LineCount, NoOfRecords);
            MakeRecurringTexts(GenJournalLine);
            CheckDocumentNo(GenJournalLine);
            GenJnlLine5.Copy(GenJournalLine);
            PrepareGenJnlLineAddCurr(GenJnlLine5);
            UpdateIncomingDocument(GenJnlLine5);
            OnBeforePostGenJnlLine(GenJnlLine5, SuppressCommit, IsPosted, GenJnlPostLine);
            if not IsPosted then
                GenJnlPostLine.RunWithoutCheck(GenJnlLine5);
            OnAfterPostGenJnlLine(GenJnlLine5, SuppressCommit, GenJnlPostLine);
            if (GenJnlTemplate.Type = GenJnlTemplate.Type::Intercompany) and (CurrentICPartner <> '') and
               ("IC Direction" = "IC Direction"::Outgoing) and (ICTransactionNo > 0)
            then
                ICOutboxMgt.CreateOutboxJnlLine(ICTransactionNo, 1, GenJnlLine5);
            if ("Recurring Method" >= "Recurring Method"::"RF Reversing Fixed") and ("Posting Date" <> 0D) then begin
                "Posting Date" := "Posting Date" + 1;
                "Document Date" := "Posting Date";
                MultiplyAmounts(GenJournalLine, -1);
                TempGenJnlLine4 := GenJournalLine;
                TempGenJnlLine4."Reversing Entry" := true;
                TempGenJnlLine4.Insert;
                NoOfReversingRecords := NoOfReversingRecords + 1;
                "Posting Date" := "Posting Date" - 1;
                "Document Date" := "Posting Date";
            end;
            PostAllocations(GenJournalLine, false);
            if TmpWithholdingContribution.Get("Journal Template Name", "Journal Batch Name", "Line No.") then
                WithholdingContribution.PostPayments(TmpWithholdingContribution, GenJournalLine, false);
        end;
        exit(true);
    end;

    local procedure CheckLine(var GenJnlLine: Record "Gen. Journal Line"; var PostingAfterCurrentFiscalYearConfirmed: Boolean)
    var
        GenJournalLineToUpdate: Record "Gen. Journal Line";
        IsModified: Boolean;
    begin
        GenJournalLineToUpdate.Copy(GenJnlLine);
        CheckRecurringLine(GenJournalLineToUpdate);
        IsModified := UpdateRecurringAmt(GenJournalLineToUpdate);
        CheckAllocations(GenJournalLineToUpdate);
        GenJnlLine5.Copy(GenJournalLineToUpdate);
        if not PostingAfterCurrentFiscalYearConfirmed then
            PostingAfterCurrentFiscalYearConfirmed :=
              PostingSetupMgt.ConfirmPostingAfterCurrentCalendarDate(
                ConfirmPostingAfterCurrentPeriodQst, GenJnlLine5."Posting Date");
        PrepareGenJnlLineAddCurr(GenJnlLine5);
        GenJnlCheckLine.RunCheck(GenJnlLine5);
        CheckRestrictions(GenJnlLine5);
        GenJnlLine.Copy(GenJournalLineToUpdate);
        if IsModified then
            GenJnlLine.Modify;
    end;

    procedure SetSuppressCommit(NewSuppressCommit: Boolean)
    begin
        SuppressCommit := NewSuppressCommit;
    end;

    local procedure IsNonZeroAmount(GenJournalLine: Record "Gen. Journal Line") Result: Boolean
    begin
        Result := GenJournalLine.Amount <> 0;
        OnAfterIsNonZeroAmount(GenJournalLine, Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCode(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; CommitIsSuppressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProcessLines(var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBalance(GenJnlTemplate: Record "Gen. Journal Template"; GenJnlLine: Record "Gen. Journal Line"; CurrentBalance: Decimal; CurrentBalanceReverse: Decimal; CurrencyBalance: Decimal; StartLineNo: Integer; StartLineNoReverse: Integer; LastDocType: Option; LastDocNo: Code[20]; LastDate: Date; LastCurrencyCode: Code[10]; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckCorrection(GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckGenPostingType(GenJnlLine: Record "Gen. Journal Line"; AccountType: Option; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCommit(GLRegNo: Integer; var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIfCheckBalance(GenJnlTemplate: Record "Gen. Journal Template"; GenJnlLine: Record "Gen. Journal Line"; var LastDocType: Option; var LastDocNo: Code[20]; var LastDate: Date; var CheckIfBalance: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAllocations(var AllocateGenJnlLine: Record "Gen. Journal Line"; Reversing: Boolean; IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; CommitIsSuppressed: Boolean; var Posted: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessLines(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessBalanceOfLines(var GenJournalLine: Record "Gen. Journal Line"; var GenJournalBatch: Record "Gen. Journal Batch"; var GenJournalTemplate: Record "Gen. Journal Template"; var IsKeySet: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRaiseExceedLengthError(var GenJournalBatch: Record "Gen. Journal Batch"; var RaiseError: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeThrowPreviewError(var GenJournalLine: Record "Gen. Journal Line"; GLRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateAndDeleteLines(var GenJournalLine: Record "Gen. Journal Line"; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateIncomingDocument(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIncrementBatchName(var GenJournalBatch: Record "Gen. Journal Batch"; OldBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAllocations(GenJournalLine: Record "Gen. Journal Line"; Reversing: Boolean; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMakeRecurringTexts(var GenJournalLine: Record "Gen. Journal Line"; var AccountingPeriod: Record "Accounting Period"; var Day: Integer; var Week: Integer; var Month: Integer; var MonthText: Text[30])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAllocationsOnBeforeCopyFromGenJnlAlloc(var GenJournalLine: Record "Gen. Journal Line"; var AllocateGenJournalLine: Record "Gen. Journal Line"; var Reversing: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMultiplyAmounts(var GenJournalLine: Record "Gen. Journal Line"; Factor: Decimal; CommitIsSuppressed: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversingLines(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnAfterProcessBalanceOfLines(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateLineBalance(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAllocationsOnBeforePostNotReversingLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAllocationsOnBeforePostReversingLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostReversingLinesOnBeforeGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessLinesOnAfterAssignGLNegNo(var GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; GLRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProcessLinesOnAfterPostGenJnlLines(GenJournalLine: Record "Gen. Journal Line"; GLRegister: Record "G/L Register"; var GLRegNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsNonZeroAmount(GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean)
    begin
    end;
}

