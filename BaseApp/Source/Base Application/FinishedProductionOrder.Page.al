﻿page 99000867 "Finished Production Order"
{
    Caption = 'Finished Production Order';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Order';
    RefreshOnActivate = true;
    SourceTable = "Production Order";
    SourceTableView = WHERE(Status = CONST(Finished));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the description of the production order.';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies an additional part of the production order description.';
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the source type of the production order.';
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the search description.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies how many units of the item or the family to produce (production quantity).';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the due date of the production order.';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies when the production order card was last modified.';
                }
            }
            part(ProdOrderLines; "Finished Prod. Order Lines")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Prod. Order No." = FIELD("No.");
            }
            group(Schedule)
            {
                Caption = 'Schedule';
                field("Starting Time"; StartingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Time';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the starting time of the production order.';
                }
                field("Starting Date"; StartingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Starting Date';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the starting date of the production order.';
                }
                field("Ending Time"; EndingTime)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Time';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ending time of the production order.';
                }
                field("Ending Date"; EndingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ending Date';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the ending date of the production order.';
                }
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies links between business transactions made for the item and an inventory account in the general ledger, to group amounts for that item type.';
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Editable = false;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the location code to which you want to post the finished product from this production order.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("O&rder")
            {
                Caption = 'O&rder';
                Image = "Order";
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        RunObject = Page "Item Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the item ledger entries of the item on the document or journal line.';
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        RunObject = Page "Capacity Ledger Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the capacity ledger entries of the involved production order. Capacity is recorded either as time (run time, stop time, or setup time) or as quantity (scrap quantity or output quantity).';
                    }
                    action("Value Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Value Entries';
                        Image = ValueLedger;
                        RunObject = Page "Value Entries";
                        RunPageLink = "Order Type" = CONST(Production),
                                      "Order No." = FIELD("No.");
                        RunPageView = SORTING("Order Type", "Order No.");
                        ToolTip = 'View the value entries of the item on the document or journal line.';
                    }
                    action("&Warehouse Entries")
                    {
                        ApplicationArea = Warehouse;
                        Caption = '&Warehouse Entries';
                        Image = BinLedger;
                        RunObject = Page "Warehouse Entries";
                        RunPageLink = "Source Type" = FILTER(83 | 5407),
                                      "Source Subtype" = FILTER("3" | "4" | "5"),
                                      "Source No." = FIELD("No.");
                        RunPageView = SORTING("Source Type", "Source Subtype", "Source No.");
                        ToolTip = 'View the history of quantities that are registered for the item in warehouse activities. ';
                    }
                }
                action("Co&mments")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Prod. Order Comment Sheet";
                    RunPageLink = Status = FIELD(Status),
                                  "Prod. Order No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                action(Statistics)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Production Order Statistics";
                    RunPageLink = Status = FIELD(Status),
                                  "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Registered P&ick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Registered P&ick Lines';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Act.-Lines";
                    RunPageLink = "Source Type" = CONST(5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                    ToolTip = 'View the list of warehouse picks that have been made for the order.';
                }
                action("<Action2>")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Registered Invt. M&ovement Lines';
                    Image = RegisteredDocs;
                    RunObject = Page "Reg. Invt. Movement Lines";
                    RunPageLink = "Source Type" = CONST(5407),
                                  "Source Subtype" = CONST("3"),
                                  "Source No." = FIELD("No.");
                    RunPageView = SORTING("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                    ToolTip = 'View the list of inventory movements that have been made for the order.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetStartingEndingDateAndTime(StartingTime, StartingDate, EndingTime, EndingDate);
    end;

    var
        StartingTime: Time;
        EndingTime: Time;
        StartingDate: Date;
        EndingDate: Date;
}

