page 12186 "Subform Vendor Bill Lines"
{
    Caption = 'Lines';
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Vendor Bill Line";

    layout
    {
        area(content)
        {
            repeater(Control1130000)
            {
                ShowCaption = false;
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the vendor''s identification number from the original purchase transaction.';
                }
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the vendor''s name from the original purchase transaction.';
                }
                field("Manual Line"; "Manual Line")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the vendor bill line was entered manually.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description for the bill line.';
                    Visible = false;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an additional description for the bill line.';
                    Visible = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the type of document that is the source of the vendor bill.';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the transaction date of the source document that generated the original purchase transaction.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies a unique identification number that refers to the source document that generated the original purchase transaction.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies an identification number, using the numbering system of the vendor, which links the vendor''s source document to the vendor bill.';
                }
                field("Cumulative Transfers"; "Cumulative Transfers")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the vendor bill entry is included in a cumulative bank transfer.';
                }
                field("Instalment Amount"; "Instalment Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount due for the current installment payment.';
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the original purchase that has not yet been paid.';
                }
                field("Amount to Pay"; "Amount to Pay")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount due for the vendor bill line.';
                }
                field("Withholding Tax Amount"; "Withholding Tax Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of withholding tax that is due for the vendor bill.';
                }
                field("Social Security Amount"; "Social Security Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount of Social Security tax that is due for the vendor bill line.';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the due date for the payment amount.';
                }
                field("Vendor Bank Acc. No."; "Vendor Bank Acc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor''s bank account number from the original purchase transaction.';
                }
                field("Beneficiary Value Date"; "Beneficiary Value Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the transferred funds from vendor bill are available for use by the vendor.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("V&end. Bill Lines")
            {
                Caption = 'V&end. Bill Lines';
                action(InvoiceCard)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Invoice Card';
                    ToolTip = 'View the related card.';

                    trigger OnAction()
                    begin
                        ShowInvoice;
                    end;
                }
                action(Dimension)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimension';
                    ToolTip = 'View the related dimension.';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
                action(WithholdingINPS)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Withholding-INPS';
                    Image = SocialSecurityTax;
                    ToolTip = 'View the withholding tax for INPS.';

                    trigger OnAction()
                    begin
                        ShowVendorBillWithhTax(true);
                    end;
                }
            }
        }
    }
}

