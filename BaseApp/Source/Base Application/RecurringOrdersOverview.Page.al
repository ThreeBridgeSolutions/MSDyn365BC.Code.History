page 15000303 "Recurring Orders Overview"
{
    Caption = 'Recurring Orders Overview';
    PageType = List;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order number.';
                }
                field("Sell-to Customer No."; "Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer that products on the order are sold to.';
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the customer that products on the order are sold to.';
                }
                field("Recurring Group Code"; "Recurring Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the recurring group code associated with the sales header.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Recurring")
            {
                Caption = '&Recurring';
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Blanket Sales Order";
                    RunPageOnRec = true;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';
                }
            }
        }
    }
}

