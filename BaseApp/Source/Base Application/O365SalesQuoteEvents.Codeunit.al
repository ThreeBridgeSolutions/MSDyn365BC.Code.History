codeunit 2163 "O365 Sales Quote Events"
{
    Permissions = TableData "Calendar Event" = rimd;
    TableNo = "Calendar Event";

    trigger OnRun()
    begin
        if not IsInvoicing then begin
            Result := NotInvoicingErr;
            State := State::Failed;
            exit;
        end;

        ParseEvent(Rec);
    end;

    var
        EstimateSentMsg: Label 'Estimate %1 is being sent.', Comment = '%1=The estimate number';
        EstimateAcceptedMsg: Label 'Estimate %1 was accepted.', Comment = '%1=The estimate number';
        EstimateExpiringMsg: Label 'There are expiring estimates.';
        UnsupportedTypeErr: Label 'This event type is not supported.';
        NotInvoicingErr: Label 'This event is only handled for Invoicing.';

    local procedure ParseEvent(CalendarEvent: Record "Calendar Event")
    var
        O365SalesEvent: Record "O365 Sales Event";
        O365SalesWebService: Codeunit "O365 Sales Web Service";
    begin
        O365SalesEvent.LockTable;
        O365SalesEvent.Get(CalendarEvent."Record ID to Process");

        case O365SalesEvent.Type of
            O365SalesEvent.Type::"Estimate Accepted":
                O365SalesWebService.SendEstimateAcceptedEvent(O365SalesEvent."Document No.");
            O365SalesEvent.Type::"Estimate Email Failed": // Generated by subscriber in COD2162
                O365SalesWebService.SendEstimateEmailFailedEvent(O365SalesEvent."Document No.");
            O365SalesEvent.Type::"Estimate Expiring":
                O365SalesWebService.SendEstimateExpiryEvent;
            O365SalesEvent.Type::"Estimate Sent":
                O365SalesWebService.SendEstimateSentEvent(O365SalesEvent."Document No.");
            else
                Error(UnsupportedTypeErr);
        end;
    end;

    local procedure UpdateExpiringEvent()
    var
        O365C2GraphEventSettings: Record "O365 C2Graph Event Settings";
        CalendarEvent: Record "Calendar Event";
        SalesHeader: Record "Sales Header";
        O365SalesEvent: Record "O365 Sales Event";
        CalendarEventMangement: Codeunit "Calendar Event Mangement";
        NewDate: Date;
        EventNo: Integer;
    begin
        if not O365C2GraphEventSettings.Get then
            O365C2GraphEventSettings.Insert(true);

        // If there are any unaccepted estimates that are expiring next week
        // Create/update the event
        NewDate := CalcDate(StrSubstNo('<WD%1>', O365C2GraphEventSettings."Est. Expiring Week Start (WD)"), Today); // Next start of the week

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Quote Accepted", false);
        SalesHeader.SetRange("Quote Valid Until Date", NewDate, CalcDate('<1W>', NewDate)); // ends some time during next week

        if CalendarEvent.Get(O365C2GraphEventSettings."Est. Expiring Event") and (not CalendarEvent.Archived) then begin
            if SalesHeader.IsEmpty then
                CalendarEvent.Delete(true)
            else begin
                CalendarEvent.Validate("Scheduled Date", NewDate);
                CalendarEvent.Modify(true);
            end;

            exit;
        end;

        if SalesHeader.IsEmpty then
            exit;

        CreateEvent(O365SalesEvent, O365SalesEvent.Type::"Estimate Expiring", '');
        EventNo :=
          CalendarEventMangement.CreateCalendarEvent(
            NewDate, EstimateExpiringMsg, CODEUNIT::"O365 Sales Quote Events", O365SalesEvent.RecordId,
            O365C2GraphEventSettings."Est. Expiring Enabled");

        O365C2GraphEventSettings."Est. Expiring Event" := EventNo;
        O365C2GraphEventSettings.Modify(true);
    end;

    local procedure CreateSendEvent(DocNo: Code[20])
    var
        O365SalesEvent: Record "O365 Sales Event";
        CalendarEventMangement: Codeunit "Calendar Event Mangement";
    begin
        CreateEvent(O365SalesEvent, O365SalesEvent.Type::"Estimate Sent", DocNo);
        CalendarEventMangement.CreateCalendarEvent(
          Today, StrSubstNo(EstimateSentMsg, DocNo), CODEUNIT::"O365 Sales Quote Events", O365SalesEvent.RecordId,
          O365SalesEvent.IsEventTypeEnabled(O365SalesEvent.Type::"Estimate Sent"));
    end;

    local procedure CreateAcceptedEvent(DocNo: Code[20])
    var
        O365SalesEvent: Record "O365 Sales Event";
        CalendarEventMangement: Codeunit "Calendar Event Mangement";
    begin
        CreateEvent(O365SalesEvent, O365SalesEvent.Type::"Estimate Accepted", DocNo);
        CalendarEventMangement.CreateCalendarEvent(
          Today, StrSubstNo(EstimateAcceptedMsg, DocNo), CODEUNIT::"O365 Sales Quote Events",
          O365SalesEvent.RecordId,
          O365SalesEvent.IsEventTypeEnabled(O365SalesEvent.Type::"Estimate Accepted"));
    end;

    local procedure CreateEvent(var O365SalesEvent: Record "O365 Sales Event"; Type: Integer; DocNo: Code[20])
    begin
        O365SalesEvent.Init;
        O365SalesEvent.Type := Type;
        O365SalesEvent."Document No." := DocNo;
        O365SalesEvent.Insert;
    end;

    local procedure IsQuote(var SalesHeader: Record "Sales Header"): Boolean
    begin
        if SalesHeader.IsTemporary then
            exit(false);

        exit(SalesHeader."Document Type" = SalesHeader."Document Type"::Quote);
    end;

    local procedure IsInvoicing(): Boolean
    var
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
        O365C2GraphEventSettings: Record "O365 C2Graph Event Settings";
        O365SalesEvent: Record "O365 Sales Event";
    begin
        if not O365SalesInitialSetup.ReadPermission then
            exit(false);

        if not (O365C2GraphEventSettings.ReadPermission and O365C2GraphEventSettings.WritePermission) then
            exit(false);

        if not (O365SalesEvent.ReadPermission and O365SalesEvent.WritePermission) then
            exit(false);

        if not O365SalesInitialSetup.Get then
            exit(false);

        exit(O365SalesInitialSetup."Is initialized");
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', false, false)]
    [Scope('OnPrem')]
    procedure OnAfterSalesHeaderInsert(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not IsQuote(Rec) then
            exit;

        if not IsInvoicing then
            exit;

        UpdateExpiringEvent;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterDeleteEvent', '', false, false)]
    [Scope('OnPrem')]
    procedure OnAfterSalesHeaderDelete(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not (IsInvoicing and IsQuote(Rec)) then
            exit;

        UpdateExpiringEvent;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterSalesHeaderModify(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; RunTrigger: Boolean)
    begin
        if not IsQuote(Rec) then
            exit;

        if not IsInvoicing then
            exit;

        UpdateExpiringEvent;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterSalesQuoteAccepted', '', false, false)]
    local procedure OnAfterSalesQuoteAccepted(var SalesHeader: Record "Sales Header")
    begin
        if not IsQuote(SalesHeader) then
            exit;

        if not IsInvoicing then
            exit;

        CreateAcceptedEvent(SalesHeader."No.");
        UpdateExpiringEvent;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterSendSalesHeader', '', false, false)]
    local procedure OnAfterSendSalesHeader(var SalesHeader: Record "Sales Header"; ShowDialog: Boolean)
    begin
        if not IsQuote(SalesHeader) then
            exit;

        if not IsInvoicing then
            exit;

        if ShowDialog then
            exit;

        CreateSendEvent(SalesHeader."No.");
    end;
}

