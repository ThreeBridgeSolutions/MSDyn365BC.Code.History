codeunit 740 "VAT Report Mediator"
{

    trigger OnRun()
    begin
    end;

    var
        VATReportReleaseReopen: Codeunit "VAT Report Release/Reopen";
        Text001: Label 'This action will also mark the report as released. Are you sure you want to continue?';

    procedure GetLines(VATReportHeader: Record "VAT Report Header")
    begin
        VATReportHeader.TestField(Status, VATReportHeader.Status::Open);
        if VATReportHeader."VAT Report Type" in [VATReportHeader."VAT Report Type"::Corrective,
                                                 VATReportHeader."VAT Report Type"::"Cancellation "]
        then
            VATReportHeader.TestField("Original Report No.");

        VATReportHeader.TestField("VAT Report Config. Code");

        VATReportHeader.SetRange("No.", VATReportHeader."No.");
        if VATReportHeader.isDatifattura then
            REPORT.RunModal(REPORT::"Datifattura Suggest Lines", false, false, VATReportHeader)
        else
            REPORT.RunModal(REPORT::"VAT Report Suggest Lines", false, false, VATReportHeader);
    end;

    procedure Export(VATReportHeader: Record "VAT Report Header")
    var
        VATReportExport: Codeunit "VAT Report Export";
    begin
        VATReportExport.Export(VATReportHeader);
    end;

    procedure Release(VATReportHeader: Record "VAT Report Header")
    begin
        VATReportReleaseReopen.Release(VATReportHeader);
    end;

    procedure Reopen(VATReportHeader: Record "VAT Report Header")
    begin
        VATReportReleaseReopen.Reopen(VATReportHeader);
    end;

    procedure Print(VATReportHeader: Record "VAT Report Header")
    begin
        case VATReportHeader.Status of
            VATReportHeader.Status::Open:
                PrintOpen(VATReportHeader);
            VATReportHeader.Status::Released:
                PrintReleased(VATReportHeader);
            VATReportHeader.Status::Submitted:
                PrintReleased(VATReportHeader);
        end;
    end;

    local procedure PrintOpen(var VATReportHeader: Record "VAT Report Header")
    var
        VATReportReleaseReopen: Codeunit "VAT Report Release/Reopen";
    begin
        VATReportHeader.TestField(Status, VATReportHeader.Status::Open);
        if Confirm(Text001, true) then begin
            VATReportReleaseReopen.Release(VATReportHeader);
            Commit;
            PrintReleased(VATReportHeader);
        end
    end;

    local procedure PrintReleased(var VATReportHeader: Record "VAT Report Header")
    begin
        VATReportHeader.SetRange("No.", VATReportHeader."No.");
        if not VATReportHeader.isDatifattura then
            REPORT.RunModal(REPORT::"VAT Report Print", true, false, VATReportHeader);
    end;

    procedure Submit(VATReportHeader: Record "VAT Report Header")
    begin
        VATReportReleaseReopen.Submit(VATReportHeader);
    end;
}

