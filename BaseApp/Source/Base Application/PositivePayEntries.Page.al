page 1231 "Positive Pay Entries"
{
    Caption = 'Positive Pay Entries';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Positive Pay Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the bank account number. If you select Balance at Date, the balance as of the last day in the relevant time interval is displayed.';
                }
                field("Upload Date"; DT2Date("Upload Date-Time"))
                {
                    ApplicationArea = Suite;
                    Caption = 'Upload Date';
                    Editable = false;
                    ToolTip = 'Specifies the date when the Positive Pay file was uploaded.';
                }
                field("Upload Time"; DT2Time("Upload Date-Time"))
                {
                    ApplicationArea = Suite;
                    Caption = 'Upload Time';
                    Editable = false;
                    ToolTip = 'Specifies the time when the Positive Pay file was uploaded.';
                }
                field("Last Upload Date"; "Last Upload Date")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the last date that you exported a Positive Pay file.';
                }
                field("Last Upload Time"; "Last Upload Time")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the last time that you exported a Positive Pay file.';
                }
                field("Number of Uploads"; "Number of Uploads")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies how many times the related Positive Pay file was uploaded.';
                }
                field("Number of Checks"; "Number of Checks")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies how many checks were processed with the Positive Pay entry.';
                }
                field("Number of Voids"; "Number of Voids")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies how many of the related checks were voided.';
                }
                field("Check Amount"; "Check Amount")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the amount on the check.';
                }
                field("Void Amount"; "Void Amount")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the amount in the Positive Pay file that is related to voided checks.';
                }
                field("Confirmation Number"; "Confirmation Number")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the confirmation number that you receive when the file upload to the bank is successful.';
                }
                field("Upload Date-Time"; "Upload Date-Time")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies when the Positive Pay file was uploaded.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Bank Acc.")
            {
                Caption = '&Bank Acc.';
                Image = Bank;
                action(PositivePayEntryDetails)
                {
                    ApplicationArea = Suite;
                    Caption = 'Positive Pay Entry Details';
                    Image = CheckLedger;
                    RunObject = Page "Positive Pay Entry Details";
                    RunPageLink = "Bank Account No." = FIELD(FILTER("Bank Account No.")),
                                  "Upload Date-Time" = FIELD("Upload Date-Time");
                    ToolTip = 'Specifies the positive pay entries. If you select Net Change, the net change in the balance is displayed for the relevant time interval.';
                }
                action(ReexportPositivePay)
                {
                    ApplicationArea = Suite;
                    Caption = 'Reexport Positive Pay to File';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Export the Positive Pay file again.';

                    trigger OnAction()
                    begin
                        Reexport;
                    end;
                }
            }
        }
    }
}

