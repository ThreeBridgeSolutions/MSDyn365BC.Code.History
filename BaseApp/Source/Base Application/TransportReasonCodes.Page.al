page 12157 "Transport Reason Codes"
{
    Caption = 'Transport Reason Codes';
    PageType = List;
    SourceTable = "Transport Reason Code";

    layout
    {
        area(content)
        {
            repeater(Control1130000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a transport reason code that you want the program to attach to the entry.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of what the code stands for.';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason codes that are associated with the transport reason codes.';
                }
                field("Posted Shpt. Nos."; "Posted Shpt. Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series that is assigned to the subcontracting shipment reason codes.';
                }
                field("Posted Rcpt. Nos."; "Posted Rcpt. Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series that is assigned to the subcontracting receiving reason codes.';
                }
            }
        }
    }

    actions
    {
    }
}

