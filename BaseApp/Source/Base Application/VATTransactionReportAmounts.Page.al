page 12199 "VAT Transaction Report Amounts"
{
    Caption = 'VAT Transaction Report Amounts';
    PageType = Card;
    SourceTable = "VAT Transaction Report Amount";

    layout
    {
        area(content)
        {
            repeater(Control1130000)
            {
                ShowCaption = false;
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the start date for the threshold amounts.';
                }
                field("Threshold Amount Incl. VAT"; "Threshold Amount Incl. VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the minimum invoice amount, including VAT, that will be included in the VAT transaction report.';
                }
                field("Threshold Amount Excl. VAT"; "Threshold Amount Excl. VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the minimum invoice base amount that will be included in the VAT transaction report.';
                }
            }
        }
    }

    actions
    {
    }
}

