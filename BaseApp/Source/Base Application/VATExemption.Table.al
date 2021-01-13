table 12186 "VAT Exemption"
{
    Caption = 'VAT Exemption';
    DrillDownPageID = "VAT Exemptions";
    LookupPageID = "VAT Exemptions";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor';
            OptionMembers = Customer,Vendor;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Customer)) Customer
            ELSE
            IF (Type = CONST(Vendor)) Vendor;
        }
        field(3; "VAT Exempt. Starting Date"; Date)
        {
            Caption = 'VAT Exempt. Starting Date';
            NotBlank = true;

            trigger OnValidate()
            var
                VATExemption: Record "VAT Exemption";
            begin
                if Type = Type::Vendor then
                    "VAT Exempt. No." := Format("VAT Exempt. Starting Date", 0, 9);

                if ("VAT Exempt. Ending Date" <> 0D) and ("VAT Exempt. Ending Date" < "VAT Exempt. Starting Date") then
                    Error(Text12100, FieldCaption("VAT Exempt. Ending Date"), FieldCaption("VAT Exempt. Starting Date"));

                VATExemption.SetRange(Type, Type);
                VATExemption.SetRange("No.", "No.");
                VATExemption.SetFilter("VAT Exempt. No.", '<>%1', "VAT Exempt. No.");
                VATExemption.SetFilter("VAT Exempt. Ending Date", '>=%1', "VAT Exempt. Starting Date");
                if VATExemption.FindFirst then
                    Error(Text12101);
            end;
        }
        field(4; "VAT Exempt. Ending Date"; Date)
        {
            Caption = 'VAT Exempt. Ending Date';
            NotBlank = true;

            trigger OnValidate()
            var
                VATExemption: Record "VAT Exemption";
            begin
                if "VAT Exempt. Ending Date" < "VAT Exempt. Starting Date" then
                    Error(Text12100, FieldCaption("VAT Exempt. Ending Date"), FieldCaption("VAT Exempt. Starting Date"));
                VATExemption.SetRange(Type, Type);
                VATExemption.SetRange("No.", "No.");
                VATExemption.SetFilter("VAT Exempt. No.", '<>%1', "VAT Exempt. No.");
                VATExemption.SetRange("VAT Exempt. Starting Date", "VAT Exempt. Starting Date", "VAT Exempt. Ending Date");
                if VATExemption.FindFirst then
                    Error(TwoVATExemptionsInOnePeriodErr);
                VATExemption.SetRange("VAT Exempt. Starting Date");
                VATExemption.SetRange("VAT Exempt. Ending Date", "VAT Exempt. Starting Date", "VAT Exempt. Ending Date");
                if VATExemption.FindFirst then
                    Error(TwoVATExemptionsInOnePeriodErr);
            end;
        }
        field(5; "VAT Exempt. Int. Registry No."; Code[20])
        {
            Caption = 'VAT Exempt. Int. Registry No.';

            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if "VAT Exempt. Int. Registry No." <> xRec."VAT Exempt. Int. Registry No." then begin
                    SalesSetup.Get;
                    NoSeriesMgt.TestManual(SalesSetup."VAT Exemption Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(6; "VAT Exempt. Int. Registry Date"; Date)
        {
            Caption = 'VAT Exempt. Int. Registry Date';
        }
        field(7; "VAT Exempt. No."; Code[20])
        {
            Caption = 'VAT Exempt. No.';
            NotBlank = true;
        }
        field(8; "VAT Exempt. Date"; Date)
        {
            Caption = 'VAT Exempt. Date';
        }
        field(9; "VAT Exempt. Office"; Text[30])
        {
            Caption = 'VAT Exempt. Office';
        }
        field(10; Printed; Boolean)
        {
            Caption = 'Printed';
            Editable = false;
        }
        field(11; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
        }
        field(12; "Declared Operations Up To Amt."; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Declared Operations Up To Amt.';
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Declared Operations Up To Amt." <> xRec."Declared Operations Up To Amt." then
                    if not Confirm(ChangeDeclaredAmountQst, false) then
                        Error('');
            end;
        }
    }

    keys
    {
        key(Key1; Type, "No.", "VAT Exempt. Starting Date", "VAT Exempt. Ending Date", "VAT Exempt. No.")
        {
            Clustered = true;
        }
        key(Key2; Type, "No.", "VAT Exempt. Int. Registry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "VAT Exempt. Int. Registry No." = '' then
            case Type of
                Type::Customer:
                    begin
                        SalesSetup.Get;
                        if SalesSetup."VAT Exemption Nos." <> '' then
                            NoSeriesMgt.InitSeries(
                              SalesSetup."VAT Exemption Nos.", xRec."No. Series", 0D, "VAT Exempt. Int. Registry No.", "No. Series");
                    end;
                Type::Vendor:
                    begin
                        PurchSetup.Get;
                        if PurchSetup."VAT Exemption Nos." <> '' then
                            NoSeriesMgt.InitSeries(
                              PurchSetup."VAT Exemption Nos.", xRec."No. Series", 0D, "VAT Exempt. Int. Registry No.", "No. Series");
                    end;
            end;
    end;

    var
        Text12100: Label '%1 must not be prior to %2.';
        Text12101: Label 'It is not possible to insert a new VAT exemption if an active exemption exists.';
        TwoVATExemptionsInOnePeriodErr: Label 'It is not possible to have two VAT Exemptions in the same period.';
        ChangeDeclaredAmountQst: Label 'The amount should be changed by creating a declaration of intent. Are you sure you manually want to change the declared amount?';

    procedure FindCustVATExemptionOnDate(CustNo: Code[20]; VATExemptionStartingDate: Date; VATExemptionEndingDate: Date): Boolean
    begin
        SetRange(Type, Type::Customer);
        SetRange("No.", CustNo);
        SetFilter("VAT Exempt. Starting Date", '<=%1', VATExemptionStartingDate);
        SetFilter("VAT Exempt. Ending Date", '>=%1', VATExemptionEndingDate);
        exit(FindFirst);
    end;
}

