page 12103 "Withholding Tax Export"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Withholding Tax Export';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    ShowFilter = false;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control1130004)
            {
                ShowCaption = false;
                field(Year; Year)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Year';
                    MaxValue = 2999;
                    MinValue = 2000;
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the year.';
                }
                field("Signing Company Officials"; SigningCompanyOfficialsNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Signing Company Officials';
                    ShowMandatory = true;
                    TableRelation = "Company Officials";
                    ToolTip = 'Specifies the signing company officials.';
                }
                field("Prepared by"; PreparedBy)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Prepared by';
                    OptionCaption = 'Company,Tax Representative';
                    ToolTip = 'Specifies the person that the export was prepared by.';
                }
                field("Communication Number"; CommunicationNumber)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Communication Number';
                    ToolTip = 'Specifies the communication number.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ExportFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export File';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Export the withholding tax.';

                trigger OnAction()
                var
                    WithholdingTaxExport: Codeunit "Withholding Tax Export";
                begin
                    WithholdingTaxExport.Export(Year, SigningCompanyOfficialsNo, PreparedBy, CommunicationNumber);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Year := Date2DWY(WorkDate, 3);
    end;

    var
        Year: Integer;
        SigningCompanyOfficialsNo: Code[20];
        PreparedBy: Option Company,"Tax Representative";
        CommunicationNumber: Integer;
}

