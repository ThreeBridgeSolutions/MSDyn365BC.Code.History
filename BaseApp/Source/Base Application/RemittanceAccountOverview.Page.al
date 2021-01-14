page 15000006 "Remittance Account Overview"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Remittance Account Overview';
    CardPageID = "Remittance Account Card";
    DataCaptionFields = "Remittance Agreement Code";
    Editable = false;
    PageType = List;
    SourceTable = "Remittance Account";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the remittance account.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the remittance account.';
                }
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment type.';
                }
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code of the payment.';
                }
            }
        }
    }

    actions
    {
    }
}

