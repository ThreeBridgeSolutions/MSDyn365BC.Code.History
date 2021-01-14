page 10687 "SAF-T Export Card"
{
    PageType = Card;
    SourceTable = "SAF-T Export Header";
    Caption = 'SAF-T Export';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Mapping Range Code"; "Mapping Range Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the mapping range code that represents the SAF-T reporting period.';
                }
                field(StartingDate; "Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the starting date of the SAF-T reporting period.';
                }
                field(EndingDate; "Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ending date of the SAF-T reporting period.';
                }
                field(ParallelProcessing; "Parallel Processing")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the change will be processed by parallel background jobs.';
                    Enabled = IsParallelProcessingAllowed;

                    trigger OnValidate()
                    begin
                        CalcParallelProcessingEnabled();
                        CurrPage.Update();
                    end;
                }
                field("Max No. Of Jobs"; "Max No. Of Jobs")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum number of background jobs processed at the same time.';
                    Enabled = IsParallelProcessingEnabled;
                }
                field(SplitByMonth; "Split By Month")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if multiple SAF-T files will be generated per month.';
                }
                field("Header Comment"; "Header Comment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the comment that is exported to the HeaderComment XML node of the SAF-T file';
                }
                field(EarliestStartDateTime; "Earliest Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest date and time when the background job must be run.';
                    Enabled = IsParallelProcessingEnabled;
                }
                field("Folder Path"; "Folder Path")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the complete path of the public folder that the SAF-T file is exported to.';
                    Visible = not IsSaaS;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the overall status of one or more SAF-T files being generated.';
                }
                field(ExecutionStartDateTime; "Execution Start Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the SAF-T file generation was started.';
                }
                field(ExecutionEndDateTime; "Execution End Date/Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time when the SAF-T file generation was completed.';
                }
            }
            part(ExportLines; "SAF-T Export Subpage")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = ID = field(ID);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Start)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = Start;
                Caption = 'Start';
                ToolTip = 'Start the generation of the SAF-T file.';

                trigger OnAction()
                begin
                    codeunit.Run(Codeunit::"SAF-T Export Mgt.", Rec);
                    CurrPage.Update();
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = True;
                Image = ExportFile;
                Caption = 'Download File';
                ToolTip = 'Download the generated SAF-T file.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
                begin
                    SAFTExportMgt.DownloadZipFileFromExportHeader(Rec);
                end;
            }
        }
    }

    var
        IsParallelProcessingAllowed: Boolean;
        IsParallelProcessingEnabled: Boolean;
        IsSaaS: Boolean;

    trigger OnOpenPage()
    var
        SAFTExportMgt: Codeunit "SAF-T Export Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsParallelProcessingAllowed := TaskScheduler.CanCreateTask();
        if not IsParallelProcessingAllowed then
            SAFTExportMgt.ThrowNoParallelExecutionNotification();
        IsSaaS := EnvironmentInformation.IsSaaS();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        IsParallelProcessingEnabled := TaskScheduler.CanCreateTask();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcParallelProcessingEnabled();
    end;

    local procedure CalcParallelProcessingEnabled()
    begin
        IsParallelProcessingEnabled := "Parallel Processing";
    end;
}