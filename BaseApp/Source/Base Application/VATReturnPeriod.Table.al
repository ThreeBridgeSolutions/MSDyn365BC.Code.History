table 737 "VAT Return Period"
{
    Caption = 'VAT Return Period';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
        }
        field(3; "Period Key"; Code[10])
        {
            Caption = 'Period Key';
        }
        field(4; "Start Date"; Date)
        {
            Caption = 'Start Date';
        }
        field(5; "End Date"; Date)
        {
            Caption = 'End Date';
        }
        field(6; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(7; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Closed';
            OptionMembers = Open,Closed;
        }
        field(8; "Received Date"; Date)
        {
            Caption = 'Received Date';
        }
        field(20; "VAT Return No."; Code[20])
        {
            Caption = 'VAT Return No.';
            Editable = false;
        }
        field(21; "VAT Return Status"; Option)
        {
            CalcFormula = Lookup ("VAT Report Header".Status WHERE("No." = FIELD("VAT Return No.")));
            Caption = 'VAT Return Status';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'Open,Released,Submitted';
            OptionMembers = Open,Released,Submitted;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        OverdueTxt: Label 'Your VAT return is overdue since %1 (%2 days)', Comment = '%1 - date; %2 - days count';
        OpenTxt: Label 'Your VAT return is due %1 (in %2 days)', Comment = '%1 - date; %2 - days count';
        VATReportSetup: Record "VAT Report Setup";
        VATReportSetupGot: Boolean;

    local procedure GetVATReportSetup()
    begin
        if VATReportSetupGot then
            exit;

        VATReportSetup.Get;
        VATReportSetupGot := true;
    end;

    [Scope('OnPrem')]
    procedure CheckOpenOrOverdue(): Text
    begin
        GetVATReportSetup;
        if (Status = Status::Open) and ("Due Date" <> 0D) then
            case true of
                // Overdue
                ("Due Date" < WorkDate):
                    exit(StrSubstNo(OverdueTxt, "Due Date", WorkDate - "Due Date"));
                    // Open
                VATReportSetup.IsPeriodReminderCalculation and
              ("Due Date" >= WorkDate) and
              ("Due Date" <= CalcDate(VATReportSetup."Period Reminder Calculation", WorkDate)):
                    exit(StrSubstNo(OpenTxt, "Due Date", "Due Date" - WorkDate));
            end;
    end;
}

