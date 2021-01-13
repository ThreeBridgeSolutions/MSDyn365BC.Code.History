page 12173 "Fixed Due Dates"
{
    AutoSplitKey = true;
    Caption = 'Fixed Due Dates';
    DataCaptionFields = Type, "Code";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Fixed Due Dates";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Payment Days"; "Payment Days")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of days that define the period of time in which payments are allowed.';
                }
            }
        }
    }

    actions
    {
    }
}

