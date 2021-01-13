report 12191 "VAT Transaction"
{
    DefaultLayout = RDLC;
    RDLCLayout = './VATTransaction.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'VAT Transaction';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(FiscalCode; "VAT Entry")
        {
            DataItemTableView = SORTING("Fiscal Code", "Operation Occurred Date") ORDER(Ascending) WHERE("Include in VAT Transac. Rep." = CONST(true), Resident = FILTER(Resident), "Individual Person" = CONST(true), Type = FILTER(Sale | Purchase));
            RequestFilterFields = "Operation Occurred Date";
            column(USERID; UserId)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
            {
            }
            column(FiscalCode_FiscalCode__Include_in_VAT_Transac__Rep__; "Include in VAT Transac. Rep.")
            {
            }
            column(FiscalCode_FiscalCode_Resident; Resident)
            {
            }
            column(FiscalCode_FiscalCode__Individual_Person_; "Individual Person")
            {
            }
            column(FiscalCode_FiscalCode_Type; Type)
            {
            }
            column(FiscalCode__Fiscal_Code_; "Fiscal Code")
            {
            }
            column(FiscalCode__Operation_Occurred_Date_; Format("Operation Occurred Date"))
            {
            }
            column(Base___Amount; Base + Amount)
            {
            }
            column(Fiscal_Operation_Type; SetOperationType(Type, "EU Service"))
            {
            }
            column(Fiscal_Total_Amount; Base + Amount)
            {
            }
            column(FiscalCode_Entry_No_; "Entry No.")
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(VAT_Transaction_ReportCaption; VAT_Transaction_ReportCaptionLbl)
            {
            }
            column(Fiscal_CodeCaption; Fiscal_CodeCaptionLbl)
            {
            }
            column(FiscalCode__Fiscal_Code_Caption; FieldCaption("Fiscal Code"))
            {
            }
            column(FiscalCode__Operation_Occurred_Date_Caption; FiscalCode__Operation_Occurred_Date_CaptionLbl)
            {
            }
            column(Base___AmountCaption; Base___AmountCaptionLbl)
            {
            }
            column(GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group__Caption; GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group__CaptionLbl)
            {
            }
            column(OperationType; OperationTypeLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
        }
        dataitem(VATRegNo; "VAT Entry")
        {
            DataItemTableView = SORTING("VAT Registration No.", "Operation Occurred Date") ORDER(Ascending) WHERE("Include in VAT Transac. Rep." = CONST(true), "Individual Person" = CONST(false), Type = FILTER(Purchase | Sale), "VAT Registration No." = FILTER(<> ''), Resident = CONST(Resident));
            column(USERID_Control1130086; UserId)
            {
            }
            column(CurrReport_PAGENO_Control1130087; CurrReport.PageNo)
            {
            }
            column(FORMAT_TODAY_0_4__Control1130089; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME_Control1130090; COMPANYPROPERTY.DisplayName)
            {
            }
            column(VATRegNo_VATRegNo__Individual_Person_; "Individual Person")
            {
            }
            column(VATRegNo_VATRegNo_Type; Type)
            {
            }
            column(VATRegNo_VATRegNo__VAT_Registration_No__; "VAT Registration No.")
            {
            }
            column(VATRegNo_VATRegNo__Include_in_VAT_Transac__Rep__; "Include in VAT Transac. Rep.")
            {
            }
            column(VATRegNo_VATRegNo_Resident; Resident)
            {
            }
            column(VATRegNo_Amount; Amount)
            {
            }
            column(VATRegNo__VAT_Registration_No__; "VAT Registration No.")
            {
            }
            column(VATRegNo__Operation_Occurred_Date_; Format("Operation Occurred Date"))
            {
            }
            column(Base___Amount_Control1130021; Base + Amount)
            {
            }
            column(SetOperationType_Type__EU_Service__; SetOperationType(Type, "EU Service"))
            {
            }
            column(Base___Amount_Control1130032; Base + Amount)
            {
            }
            column(VATRegNo_Amount_Control1130033; Amount)
            {
            }
            column(VATRegNo_Entry_No_; "Entry No.")
            {
            }
            column(CurrReport_PAGENO_Control1130087Caption; CurrReport_PAGENO_Control1130087CaptionLbl)
            {
            }
            column(VAT_Transaction_ReportCaption_Control1130091; VAT_Transaction_ReportCaption_Control1130091Lbl)
            {
            }
            column(VAT_Registration_No_Caption; VAT_Registration_No_CaptionLbl)
            {
            }
            column(VATRegNo_AmountCaption; FieldCaption(Amount))
            {
            }
            column(VATRegNo__VAT_Registration_No__Caption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegNo__Operation_Occurred_Date_Caption; VATRegNo__Operation_Occurred_Date_CaptionLbl)
            {
            }
            column(Total_AmountCaption; Total_AmountCaptionLbl)
            {
            }
            column(GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group___Control1130022Caption; GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group___Control1130022CaptionLbl)
            {
            }
            column(SetOperationType_Type__EU_Service__Caption; SetOperationType_Type__EU_Service__CaptionLbl)
            {
            }
            column(TotalCaption_Control1130034; TotalCaption_Control1130034Lbl)
            {
            }

            trigger OnPreDataItem()
            begin
                FiscalCode.CopyFilter("Operation Occurred Date", "Operation Occurred Date");
            end;
        }
        dataitem(NonResident; "VAT Entry")
        {
            DataItemTableView = SORTING("Fiscal Code", "Operation Occurred Date") ORDER(Ascending) WHERE("Include in VAT Transac. Rep." = CONST(true), Resident = CONST("Non-Resident"), Type = FILTER(Purchase | Sale), "Individual Person" = CONST(true));
            column(USERID_Control1130092; UserId)
            {
            }
            column(CurrReport_PAGENO_Control1130093; CurrReport.PageNo)
            {
            }
            column(FORMAT_TODAY_0_4__Control1130095; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME_Control1130096; COMPANYPROPERTY.DisplayName)
            {
            }
            column(NonResident_NonResident__Include_in_VAT_Transac__Rep__; "Include in VAT Transac. Rep.")
            {
            }
            column(NonResident_NonResident__Individual_Person_; "Individual Person")
            {
            }
            column(NonResident_NonResident_Resident; Resident)
            {
            }
            column(NonResident_NonResident_Type; Type)
            {
            }
            column(NonResident__Place_of_Birth_; "Place of Birth")
            {
            }
            column(NonResident__First_Name_; "First Name")
            {
            }
            column(NonResident__Last_Name_; "Last Name")
            {
            }
            column(NonResident__Date_of_Birth_; Format("Date of Birth"))
            {
            }
            column(NonResident__Country_Region_Code_; "Country/Region Code")
            {
            }
            column(NonResident__Operation_Occurred_Date_; Format("Operation Occurred Date"))
            {
            }
            column(NonResident_Amount; Amount)
            {
            }
            column(SetOperationType_Type__EU_Service___Control1130053; SetOperationType(Type, "EU Service"))
            {
            }
            column(Base___Amount_Control1130055; Base + Amount)
            {
            }
            column(Base___Amount_Control1130056; Base + Amount)
            {
            }
            column(NonResident_Amount_Control1130057; Amount)
            {
            }
            column(NonResident_Entry_No_; "Entry No.")
            {
            }
            column(CurrReport_PAGENO_Control1130093Caption; CurrReport_PAGENO_Control1130093CaptionLbl)
            {
            }
            column(VAT_Transaction_ReportCaption_Control1130097; VAT_Transaction_ReportCaption_Control1130097Lbl)
            {
            }
            column(IndividualCaption; IndividualCaptionLbl)
            {
            }
            column(NonResident__Date_of_Birth_Caption; NonResident__Date_of_Birth_CaptionLbl)
            {
            }
            column(NonResident__Place_of_Birth_Caption; FieldCaption("Place of Birth"))
            {
            }
            column(NonResident__Country_Region_Code_Caption; FieldCaption("Country/Region Code"))
            {
            }
            column(NonResident__Operation_Occurred_Date_Caption; NonResident__Operation_Occurred_Date_CaptionLbl)
            {
            }
            column(NonResident_AmountCaption; FieldCaption(Amount))
            {
            }
            column(SetOperationType_Type__EU_Service___Control1130053Caption; SetOperationType_Type__EU_Service___Control1130053CaptionLbl)
            {
            }
            column(Base___Amount_Control1130055Caption; Base___Amount_Control1130055CaptionLbl)
            {
            }
            column(GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group___Control1130059Caption; GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group___Control1130059CaptionLbl)
            {
            }
            column(NonResident__Last_Name_Caption; FieldCaption("Last Name"))
            {
            }
            column(NonResident__First_Name_Caption; FieldCaption("First Name"))
            {
            }
            column(Non_ResidentCaption; Non_ResidentCaptionLbl)
            {
            }
            column(TotalCaption_Control1130058; TotalCaption_Control1130058Lbl)
            {
            }

            trigger OnPreDataItem()
            begin
                FiscalCode.CopyFilter("Operation Occurred Date", "Operation Occurred Date");
            end;
        }
        dataitem("VAT Entry"; "VAT Entry")
        {
            DataItemTableView = SORTING("Fiscal Code", "Operation Occurred Date") ORDER(Ascending) WHERE("Include in VAT Transac. Rep." = CONST(true), Type = FILTER(Sale), "Individual Person" = CONST(false), Resident = CONST("Non-Resident"), "VAT Registration No." = FILTER(<> ''));
            column(VAT_Entry__VAT_Entry___VAT_Registration_No__; "VAT Entry"."VAT Registration No.")
            {
            }
            column(VAT_Entry__VAT_Entry__Resident; "VAT Entry".Resident)
            {
            }
            column(VAT_Entry__VAT_Entry___Individual_Person_; "VAT Entry"."Individual Person")
            {
            }
            column(VAT_Entry__VAT_Entry___Include_in_VAT_Transac__Rep__; "VAT Entry"."Include in VAT Transac. Rep.")
            {
            }
            column(VAT_Entry__VAT_Entry__Type; "VAT Entry".Type)
            {
            }
            column(TaxRepresentativeName; TaxRepresentativeName)
            {
            }
            column(CustName; CustName)
            {
            }
            column(VAT_Entry__Country_Region_Code_; "Country/Region Code")
            {
            }
            column(VAT_Entry__Operation_Occurred_Date_; Format("Operation Occurred Date"))
            {
            }
            column(VAT_Entry_Amount; Amount)
            {
            }
            column(Base___Amount_Control1130073; Base + Amount)
            {
            }
            column(SetOperationType_Type__EU_Service___Control1130076; SetOperationType(Type, "EU Service"))
            {
            }
            column(VAT_Entry_Amount_Control1130079; Amount)
            {
            }
            column(Base___Amount_Control1130080; Base + Amount)
            {
            }
            column(VAT_Entry_Entry_No_; "Entry No.")
            {
            }
            column(CompanyCaption; CompanyCaptionLbl)
            {
            }
            column(Customer_NameCaption; Customer_NameCaptionLbl)
            {
            }
            column(TaxRepresentativeNameCaption; TaxRepresentativeNameCaptionLbl)
            {
            }
            column(VAT_Entry__Country_Region_Code_Caption; FieldCaption("Country/Region Code"))
            {
            }
            column(VAT_Entry__Operation_Occurred_Date_Caption; VAT_Entry__Operation_Occurred_Date_CaptionLbl)
            {
            }
            column(VAT_Entry_AmountCaption; FieldCaption(Amount))
            {
            }
            column(Base___Amount_Control1130073Caption; Base___Amount_Control1130073CaptionLbl)
            {
            }
            column(SetOperationType_Type__EU_Service___Control1130076Caption; SetOperationType_Type__EU_Service___Control1130076CaptionLbl)
            {
            }
            column(VAT_Transaction_TypeCaption; VAT_Transaction_TypeCaptionLbl)
            {
            }
            column(TotalCaption_Control1130078; TotalCaption_Control1130078Lbl)
            {
            }

            trigger OnAfterGetRecord()
            var
                Customer: Record Customer;
                Cont: Record Contact;
            begin
                CustName := '';
                TaxRepresentativeName := '';

                if Customer.Get("Bill-to/Pay-to No.") then begin
                    CustName := Customer.Name;
                    case Customer."Tax Representative Type" of
                        Customer."Tax Representative Type"::Customer:
                            if Customer.Get(Customer."Tax Representative No.") then
                                TaxRepresentativeName := Customer.Name;
                        Customer."Tax Representative Type"::Contact:
                            if Cont.Get(Customer."Tax Representative No.") then
                                TaxRepresentativeName := Cont.Name;
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                FiscalCode.CopyFilter("Operation Occurred Date", "Operation Occurred Date");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        Text001: Label 'Sales of Goods';
        Text002: Label 'Sales of Service';
        Text003: Label 'Purchase of Goods';
        Text004: Label 'Purchase of Service';
        CustName: Text[100];
        TaxRepresentativeName: Text[100];
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        VAT_Transaction_ReportCaptionLbl: Label 'VAT Transaction Report';
        Fiscal_CodeCaptionLbl: Label 'Fiscal Code';
        FiscalCode__Operation_Occurred_Date_CaptionLbl: Label 'Operation Occurred Date';
        Base___AmountCaptionLbl: Label 'Total Amount';
        GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group__CaptionLbl: Label 'VAT Transaction Type';
        OperationTypeLbl: Label 'Operation Type';
        TotalCaptionLbl: Label 'Total';
        CurrReport_PAGENO_Control1130087CaptionLbl: Label 'Page';
        VAT_Transaction_ReportCaption_Control1130091Lbl: Label 'VAT Transaction Report';
        VAT_Registration_No_CaptionLbl: Label 'VAT Registration No.';
        VATRegNo__Operation_Occurred_Date_CaptionLbl: Label 'Operation Occurred Date';
        Total_AmountCaptionLbl: Label 'Total Amount';
        GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group___Control1130022CaptionLbl: Label 'VAT Transaction Type';
        SetOperationType_Type__EU_Service__CaptionLbl: Label 'Operation Type';
        TotalCaption_Control1130034Lbl: Label 'Total';
        CurrReport_PAGENO_Control1130093CaptionLbl: Label 'Page';
        VAT_Transaction_ReportCaption_Control1130097Lbl: Label 'VAT Transaction Report';
        IndividualCaptionLbl: Label 'Individual';
        NonResident__Date_of_Birth_CaptionLbl: Label 'Date of Birth';
        NonResident__Operation_Occurred_Date_CaptionLbl: Label 'Operation Occurred Date';
        SetOperationType_Type__EU_Service___Control1130053CaptionLbl: Label 'Operation Type';
        Base___Amount_Control1130055CaptionLbl: Label 'Total Amount';
        GetVATTransactionType__VAT_Bus__Posting_Group___VAT_Prod__Posting_Group___Control1130059CaptionLbl: Label 'VAT Transaction Type';
        Non_ResidentCaptionLbl: Label 'Non-Resident';
        TotalCaption_Control1130058Lbl: Label 'Total';
        CompanyCaptionLbl: Label 'Company';
        Customer_NameCaptionLbl: Label 'Customer Name';
        TaxRepresentativeNameCaptionLbl: Label 'TAX Representative Name';
        VAT_Entry__Operation_Occurred_Date_CaptionLbl: Label 'Operation Occurred Date';
        Base___Amount_Control1130073CaptionLbl: Label 'Total Amount';
        SetOperationType_Type__EU_Service___Control1130076CaptionLbl: Label 'Operation Type';
        VAT_Transaction_TypeCaptionLbl: Label 'VAT Transaction Type';
        TotalCaption_Control1130078Lbl: Label 'Total';

    [Scope('OnPrem')]
    procedure SetOperationType(TransactionType: Option " ",Purchase,Sale; EUService: Boolean): Text[30]
    begin
        case TransactionType of
            TransactionType::Sale:
                begin
                    if EUService then
                        exit(Text002);
                    exit(Text001);
                end;
            TransactionType::Purchase:
                begin
                    if EUService then
                        exit(Text004);
                    exit(Text003);
                end;
        end;
    end;
}

