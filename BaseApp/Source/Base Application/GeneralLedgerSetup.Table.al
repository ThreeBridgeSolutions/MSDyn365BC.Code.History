table 98 "General Ledger Setup"
{
    Caption = 'General Ledger Setup';
    Permissions = TableData "G/L Entry" = m,
                  TableData "Cust. Ledger Entry" = m,
                  TableData "Vendor Ledger Entry" = m,
                  TableData "Sales Invoice Header" = m,
                  TableData "Sales Cr.Memo Header" = m,
                  TableData "Purch. Inv. Header" = m,
                  TableData "Purch. Cr. Memo Hdr." = m,
                  TableData "VAT Entry" = m,
                  TableData "Posted Cash Document Header" = m;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Allow Posting From"; Date)
        {
            Caption = 'Allow Posting From';

            trigger OnValidate()
            begin
                CheckAllowedPostingDates(0);
            end;
        }
        field(3; "Allow Posting To"; Date)
        {
            Caption = 'Allow Posting To';

            trigger OnValidate()
            begin
                CheckAllowedPostingDates(0);
            end;
        }
        field(4; "Register Time"; Boolean)
        {
            Caption = 'Register Time';
        }
        field(28; "Pmt. Disc. Excl. VAT"; Boolean)
        {
            Caption = 'Pmt. Disc. Excl. VAT';

            trigger OnValidate()
            begin
                if "Pmt. Disc. Excl. VAT" then
                    TestField("Adjust for Payment Disc.", false)
                else
                    TestField("VAT Tolerance %", 0);
            end;
        }
        field(41; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(42; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Global Dimension 1 Code"));
        }
        field(43; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Global Dimension 2 Code"));
        }
        field(44; "Cust. Balances Due"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Detailed Cust. Ledg. Entry"."Amount (LCY)" WHERE("Initial Entry Global Dim. 1" = FIELD("Global Dimension 1 Filter"),
                                                                                 "Initial Entry Global Dim. 2" = FIELD("Global Dimension 2 Filter"),
                                                                                 "Initial Entry Due Date" = FIELD("Date Filter")));
            Caption = 'Cust. Balances Due';
            Editable = false;
            FieldClass = FlowField;
        }
        field(45; "Vendor Balances Due"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - Sum ("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE("Initial Entry Global Dim. 1" = FIELD("Global Dimension 1 Filter"),
                                                                                   "Initial Entry Global Dim. 2" = FIELD("Global Dimension 2 Filter"),
                                                                                   "Initial Entry Due Date" = FIELD("Date Filter")));
            Caption = 'Vendor Balances Due';
            Editable = false;
            FieldClass = FlowField;
        }
        field(48; "Unrealized VAT"; Boolean)
        {
            Caption = 'Unrealized VAT';

            trigger OnValidate()
            begin
                if not "Unrealized VAT" then begin
                    VATPostingSetup.SetFilter(
                      "Unrealized VAT Type", '>=%1', VATPostingSetup."Unrealized VAT Type"::Percentage);
                    if VATPostingSetup.FindFirst then
                        Error(
                          Text000, VATPostingSetup.TableCaption,
                          VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group",
                          VATPostingSetup.FieldCaption("Unrealized VAT Type"), VATPostingSetup."Unrealized VAT Type");
                    TaxJurisdiction.SetFilter(
                      "Unrealized VAT Type", '>=%1', TaxJurisdiction."Unrealized VAT Type"::Percentage);
                    if TaxJurisdiction.FindFirst then
                        Error(
                          Text001, TaxJurisdiction.TableCaption,
                          TaxJurisdiction.Code, TaxJurisdiction.FieldCaption("Unrealized VAT Type"),
                          TaxJurisdiction."Unrealized VAT Type");
                end;
                if "Unrealized VAT" then
                    "Prepayment Unrealized VAT" := true
                else
                    "Prepayment Unrealized VAT" := false;
            end;
        }
        field(49; "Adjust for Payment Disc."; Boolean)
        {
            Caption = 'Adjust for Payment Disc.';

            trigger OnValidate()
            begin
                if "Adjust for Payment Disc." then begin
                    TestField("Pmt. Disc. Excl. VAT", false);
                    TestField("VAT Tolerance %", 0);
                end else begin
                    VATPostingSetup.SetRange("Adjust for Payment Discount", true);
                    if VATPostingSetup.FindFirst then
                        Error(
                          Text002, VATPostingSetup.TableCaption,
                          VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group",
                          VATPostingSetup.FieldCaption("Adjust for Payment Discount"));
                    TaxJurisdiction.SetRange("Adjust for Payment Discount", true);
                    if TaxJurisdiction.FindFirst then
                        Error(
                          Text003, TaxJurisdiction.TableCaption,
                          TaxJurisdiction.Code, TaxJurisdiction.FieldCaption("Adjust for Payment Discount"));
                end;
            end;
        }
        field(50; "Post with Job Queue"; Boolean)
        {
            Caption = 'Post with Job Queue';

            trigger OnValidate()
            begin
                if not "Post with Job Queue" then
                    "Post & Print with Job Queue" := false;
            end;
        }
        field(51; "Job Queue Category Code"; Code[10])
        {
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category";
        }
        field(52; "Job Queue Priority for Post"; Integer)
        {
            Caption = 'Job Queue Priority for Post';
            InitValue = 1000;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Job Queue Priority for Post" < 0 then
                    Error(Text001);
            end;
        }
        field(53; "Post & Print with Job Queue"; Boolean)
        {
            Caption = 'Post & Print with Job Queue';

            trigger OnValidate()
            begin
                if "Post & Print with Job Queue" then
                    "Post with Job Queue" := true;
            end;
        }
        field(54; "Job Q. Prio. for Post & Print"; Integer)
        {
            Caption = 'Job Q. Prio. for Post & Print';
            InitValue = 1000;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Job Queue Priority for Post" < 0 then
                    Error(Text001);
            end;
        }
        field(55; "Notify On Success"; Boolean)
        {
            Caption = 'Notify On Success';
        }
        field(56; "Mark Cr. Memos as Corrections"; Boolean)
        {
            Caption = 'Mark Cr. Memos as Corrections';
        }
        field(57; "Local Address Format"; Option)
        {
            Caption = 'Local Address Format';
            OptionCaption = 'Post Code+City,City+Post Code,City+County+Post Code,Blank Line+Post Code+City';
            OptionMembers = "Post Code+City","City+Post Code","City+County+Post Code","Blank Line+Post Code+City";
        }
        field(58; "Inv. Rounding Precision (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inv. Rounding Precision (LCY)';

            trigger OnValidate()
            begin
                if "Amount Rounding Precision" <> 0 then
                    if "Inv. Rounding Precision (LCY)" <> Round("Inv. Rounding Precision (LCY)", "Amount Rounding Precision") then
                        Error(
                          Text004,
                          FieldCaption("Inv. Rounding Precision (LCY)"), "Amount Rounding Precision");
            end;
        }
        field(59; "Inv. Rounding Type (LCY)"; Option)
        {
            Caption = 'Inv. Rounding Type (LCY)';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(60; "Local Cont. Addr. Format"; Option)
        {
            Caption = 'Local Cont. Addr. Format';
            InitValue = "After Company Name";
            OptionCaption = 'First,After Company Name,Last';
            OptionMembers = First,"After Company Name",Last;
        }
        field(61; "Report Output Type"; Option)
        {
            Caption = 'Report Output Type';
            DataClassification = CustomerContent;
            OptionCaption = 'PDF,,,Print';
            OptionMembers = PDF,,,Print;

            trigger OnValidate()
            var
                EnvironmentInformation: Codeunit "Environment Information";
            begin
                if "Report Output Type" = "Report Output Type"::Print then
                    if EnvironmentInformation.IsSaaS then
                        TestField("Report Output Type", "Report Output Type"::PDF);
            end;
        }
        field(63; "Bank Account Nos."; Code[20])
        {
            AccessByPermission = TableData "Bank Account" = R;
            Caption = 'Bank Account Nos.';
            TableRelation = "No. Series";
        }
        field(65; "Summarize G/L Entries"; Boolean)
        {
            Caption = 'Summarize G/L Entries';
        }
        field(66; "Amount Decimal Places"; Text[5])
        {
            Caption = 'Amount Decimal Places';
            InitValue = '2:2';

            trigger OnValidate()
            begin
                CheckDecimalPlacesFormat("Amount Decimal Places");
            end;
        }
        field(67; "Unit-Amount Decimal Places"; Text[5])
        {
            Caption = 'Unit-Amount Decimal Places';
            InitValue = '2:5';

            trigger OnValidate()
            begin
                CheckDecimalPlacesFormat("Unit-Amount Decimal Places");
            end;
        }
        field(68; "Additional Reporting Currency"; Code[10])
        {
            Caption = 'Additional Reporting Currency';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if ("Additional Reporting Currency" <> xRec."Additional Reporting Currency") and
                   ("Additional Reporting Currency" <> '')
                then begin
                    AdjAddReportingCurr.SetAddCurr("Additional Reporting Currency");
                    AdjAddReportingCurr.RunModal;
                    if not AdjAddReportingCurr.IsExecuted then
                        "Additional Reporting Currency" := xRec."Additional Reporting Currency";
                end;
                if ("Additional Reporting Currency" <> xRec."Additional Reporting Currency") and
                   AdjAddReportingCurr.IsExecuted
                then
                    DeleteIntrastatJnl;
                if ("Additional Reporting Currency" <> xRec."Additional Reporting Currency") and
                   ("Additional Reporting Currency" <> '') and
                   AdjAddReportingCurr.IsExecuted
                then
                    DeleteAnalysisView;
            end;
        }
        field(69; "VAT Tolerance %"; Decimal)
        {
            Caption = 'VAT Tolerance %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "VAT Tolerance %" <> 0 then begin
                    TestField("Adjust for Payment Disc.", false);
                    TestField("Pmt. Disc. Excl. VAT", true);
                end;
            end;
        }
        field(70; "EMU Currency"; Boolean)
        {
            Caption = 'EMU Currency';
        }
        field(71; "LCY Code"; Code[10])
        {
            Caption = 'LCY Code';

            trigger OnValidate()
            var
                Currency: Record Currency;
            begin
                if "Local Currency Symbol" = '' then
                    "Local Currency Symbol" := Currency.ResolveCurrencySymbol("LCY Code");

                if "Local Currency Description" = '' then
                    "Local Currency Description" := CopyStr(Currency.ResolveCurrencyDescription("LCY Code"), 1, MaxStrLen("Local Currency Description"));
            end;
        }
        field(72; "VAT Exchange Rate Adjustment"; Option)
        {
            Caption = 'VAT Exchange Rate Adjustment';
            OptionCaption = 'No Adjustment,Adjust Amount,Adjust Additional-Currency Amount';
            OptionMembers = "No Adjustment","Adjust Amount","Adjust Additional-Currency Amount";
        }
        field(73; "Amount Rounding Precision"; Decimal)
        {
            Caption = 'Amount Rounding Precision';
            DecimalPlaces = 0 : 5;
            InitValue = 0.01;

            trigger OnValidate()
            begin
                if "Amount Rounding Precision" <> 0 then
                    "Inv. Rounding Precision (LCY)" := Round("Inv. Rounding Precision (LCY)", "Amount Rounding Precision");

                RoundingErrorCheck(FieldCaption("Amount Rounding Precision"));

                if HideDialog then
                    Message(Text021);
            end;
        }
        field(74; "Unit-Amount Rounding Precision"; Decimal)
        {
            Caption = 'Unit-Amount Rounding Precision';
            DecimalPlaces = 0 : 9;
            InitValue = 0.00001;

            trigger OnValidate()
            begin
                if HideDialog then
                    Message(Text022);
            end;
        }
        field(75; "Appln. Rounding Precision"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Appln. Rounding Precision';
            MinValue = 0;
        }
        field(79; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            Editable = false;
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                "Shortcut Dimension 1 Code" := "Global Dimension 1 Code";
            end;
        }
        field(80; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            Editable = false;
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                "Shortcut Dimension 2 Code" := "Global Dimension 2 Code";
            end;
        }
        field(81; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
            Editable = false;
            TableRelation = Dimension;
        }
        field(82; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
            Editable = false;
            TableRelation = Dimension;
        }
        field(83; "Shortcut Dimension 3 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination" = R;
            Caption = 'Shortcut Dimension 3 Code';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                UpdateDimValueGlobalDimNo(xRec."Shortcut Dimension 3 Code", "Shortcut Dimension 3 Code", 3);
            end;
        }
        field(84; "Shortcut Dimension 4 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination" = R;
            Caption = 'Shortcut Dimension 4 Code';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                UpdateDimValueGlobalDimNo(xRec."Shortcut Dimension 4 Code", "Shortcut Dimension 4 Code", 4);
            end;
        }
        field(85; "Shortcut Dimension 5 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination" = R;
            Caption = 'Shortcut Dimension 5 Code';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                UpdateDimValueGlobalDimNo(xRec."Shortcut Dimension 5 Code", "Shortcut Dimension 5 Code", 5);
            end;
        }
        field(86; "Shortcut Dimension 6 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination" = R;
            Caption = 'Shortcut Dimension 6 Code';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                UpdateDimValueGlobalDimNo(xRec."Shortcut Dimension 6 Code", "Shortcut Dimension 6 Code", 6);
            end;
        }
        field(87; "Shortcut Dimension 7 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination" = R;
            Caption = 'Shortcut Dimension 7 Code';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                UpdateDimValueGlobalDimNo(xRec."Shortcut Dimension 7 Code", "Shortcut Dimension 7 Code", 7);
            end;
        }
        field(88; "Shortcut Dimension 8 Code"; Code[20])
        {
            AccessByPermission = TableData "Dimension Combination" = R;
            Caption = 'Shortcut Dimension 8 Code';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                UpdateDimValueGlobalDimNo(xRec."Shortcut Dimension 8 Code", "Shortcut Dimension 8 Code", 8);
            end;
        }
        field(89; "Max. VAT Difference Allowed"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Max. VAT Difference Allowed';

            trigger OnValidate()
            begin
                if "Max. VAT Difference Allowed" <> Round("Max. VAT Difference Allowed") then
                    Error(
                      Text004,
                      FieldCaption("Max. VAT Difference Allowed"), "Amount Rounding Precision");

                "Max. VAT Difference Allowed" := Abs("Max. VAT Difference Allowed");
            end;
        }
        field(90; "VAT Rounding Type"; Option)
        {
            Caption = 'VAT Rounding Type';
            OptionCaption = 'Nearest,Up,Down';
            OptionMembers = Nearest,Up,Down;
        }
        field(92; "Pmt. Disc. Tolerance Posting"; Option)
        {
            Caption = 'Pmt. Disc. Tolerance Posting';
            OptionCaption = 'Payment Tolerance Accounts,Payment Discount Accounts';
            OptionMembers = "Payment Tolerance Accounts","Payment Discount Accounts";
        }
        field(93; "Payment Discount Grace Period"; DateFormula)
        {
            Caption = 'Payment Discount Grace Period';
        }
        field(94; "Payment Tolerance %"; Decimal)
        {
            Caption = 'Payment Tolerance %';
            DecimalPlaces = 0 : 5;
            Editable = false;
            MaxValue = 100;
            MinValue = 0;
        }
        field(95; "Max. Payment Tolerance Amount"; Decimal)
        {
            Caption = 'Max. Payment Tolerance Amount';
            Editable = false;
            MinValue = 0;
        }
        field(96; "Adapt Main Menu to Permissions"; Boolean)
        {
            Caption = 'Adapt Main Menu to Permissions';
            InitValue = true;
        }
        field(97; "Allow G/L Acc. Deletion Before"; Date)
        {
            Caption = 'Allow G/L Acc. Deletion Before';
        }
        field(98; "Check G/L Account Usage"; Boolean)
        {
            Caption = 'Check G/L Account Usage';
        }
        field(99; "Payment Tolerance Posting"; Option)
        {
            Caption = 'Payment Tolerance Posting';
            OptionCaption = 'Payment Tolerance Accounts,Payment Discount Accounts';
            OptionMembers = "Payment Tolerance Accounts","Payment Discount Accounts";
        }
        field(100; "Pmt. Disc. Tolerance Warning"; Boolean)
        {
            Caption = 'Pmt. Disc. Tolerance Warning';
        }
        field(101; "Payment Tolerance Warning"; Boolean)
        {
            Caption = 'Payment Tolerance Warning';
        }
        field(102; "Last IC Transaction No."; Integer)
        {
            Caption = 'Last IC Transaction No.';
        }
        field(103; "Bill-to/Sell-to VAT Calc."; Option)
        {
            Caption = 'Bill-to/Sell-to VAT Calc.';
            OptionCaption = 'Bill-to/Pay-to No.,Sell-to/Buy-from No.';
            OptionMembers = "Bill-to/Pay-to No.","Sell-to/Buy-from No.";
        }
        field(110; "Acc. Sched. for Balance Sheet"; Code[10])
        {
            Caption = 'Acc. Sched. for Balance Sheet';
            TableRelation = "Acc. Schedule Name";
        }
        field(111; "Acc. Sched. for Income Stmt."; Code[10])
        {
            Caption = 'Acc. Sched. for Income Stmt.';
            TableRelation = "Acc. Schedule Name";
        }
        field(112; "Acc. Sched. for Cash Flow Stmt"; Code[10])
        {
            Caption = 'Acc. Sched. for Cash Flow Stmt';
            TableRelation = "Acc. Schedule Name";
        }
        field(113; "Acc. Sched. for Retained Earn."; Code[10])
        {
            Caption = 'Acc. Sched. for Retained Earn.';
            TableRelation = "Acc. Schedule Name";
        }
        field(120; "Tax Invoice Renaming Threshold"; Decimal)
        {
            Caption = 'Tax Invoice Renaming Threshold';
            DataClassification = SystemMetadata;
        }
        field(150; "Print VAT specification in LCY"; Boolean)
        {
            Caption = 'Print VAT specification in LCY';
        }
        field(151; "Prepayment Unrealized VAT"; Boolean)
        {
            Caption = 'Prepayment Unrealized VAT';

            trigger OnValidate()
            begin
                if "Unrealized VAT" and xRec."Prepayment Unrealized VAT" then
                    Error(DependentFieldActivatedErr, FieldCaption("Prepayment Unrealized VAT"), FieldCaption("Unrealized VAT"));

                if not "Prepayment Unrealized VAT" then begin
                    VATPostingSetup.SetFilter(
                      "Unrealized VAT Type", '>=%1', VATPostingSetup."Unrealized VAT Type"::Percentage);
                    if VATPostingSetup.FindFirst then
                        Error(
                          Text000, VATPostingSetup.TableCaption,
                          VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group",
                          VATPostingSetup.FieldCaption("Unrealized VAT Type"), VATPostingSetup."Unrealized VAT Type");
                    TaxJurisdiction.SetFilter(
                      "Unrealized VAT Type", '>=%1', TaxJurisdiction."Unrealized VAT Type"::Percentage);
                    if TaxJurisdiction.FindFirst then
                        Error(
                          Text001, TaxJurisdiction.TableCaption,
                          TaxJurisdiction.Code, TaxJurisdiction.FieldCaption("Unrealized VAT Type"),
                          TaxJurisdiction."Unrealized VAT Type");
                end;
            end;
        }
        field(152; "Use Legacy G/L Entry Locking"; Boolean)
        {
            Caption = 'Use Legacy G/L Entry Locking';

            trigger OnValidate()
            var
                InventorySetup: Record "Inventory Setup";
            begin
                if not "Use Legacy G/L Entry Locking" then begin
                    if InventorySetup.Get then
                        if InventorySetup."Automatic Cost Posting" then
                            Error(Text025,
                              FieldCaption("Use Legacy G/L Entry Locking"),
                              "Use Legacy G/L Entry Locking",
                              InventorySetup.FieldCaption("Automatic Cost Posting"),
                              InventorySetup.TableCaption,
                              InventorySetup."Automatic Cost Posting");
                end;
            end;
        }
        field(160; "Payroll Trans. Import Format"; Code[20])
        {
            Caption = 'Payroll Trans. Import Format';
            TableRelation = "Data Exch. Def" WHERE(Type = CONST("Payroll Import"));
        }
        field(161; "VAT Reg. No. Validation URL"; Text[250])
        {
            Caption = 'VAT Reg. No. Validation URL';
            ObsoleteReason = 'This field is obsolete, it has been replaced by Table 248 VAT Reg. No. Srv Config.';
            ObsoleteState = Pending;

            trigger OnValidate()
            begin
                Error(ObsoleteErr);
            end;
        }
        field(162; "Local Currency Symbol"; Text[10])
        {
            Caption = 'Local Currency Symbol';
        }
        field(163; "Local Currency Description"; Text[60])
        {
            Caption = 'Local Currency Description';
        }
        field(164; "Show Amounts"; Option)
        {
            Caption = 'Show Amounts';
            OptionCaption = 'Amount Only,Debit/Credit Only,All Amounts';
            OptionMembers = "Amount Only","Debit/Credit Only","All Amounts";
        }
        field(170; "SEPA Non-Euro Export"; Boolean)
        {
            Caption = 'SEPA Non-Euro Export';
        }
        field(171; "SEPA Export w/o Bank Acc. Data"; Boolean)
        {
            Caption = 'SEPA Export w/o Bank Acc. Data';
        }
        field(11730; "Cash Desk Nos."; Code[20])
        {
            Caption = 'Cash Desk Nos.';
            TableRelation = "No. Series";
        }
        field(11731; "Cash Payment Limit (LCY)"; Decimal)
        {
            Caption = 'Cash Payment Limit (LCY)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(11760; "Closed Period Entry Pos.Date"; Date)
        {
            Caption = 'Closed Period Entry Pos.Date';
        }
        field(11761; "Rounding Date"; Date)
        {
            Caption = 'Rounding Date';
        }
        field(11762; "Statement Templ. Name Coeff."; Code[10])
        {
            Caption = 'Statement Templ. Name Coeff.';
            TableRelation = "VAT Statement Template";
            ObsoleteState = Pending;
            ObsoleteReason = 'The functionality of Non-deductible VAT will be removed and this field should not be used. (Obsolete::Removed in release 01.2021)';

            trigger OnValidate()
            begin
                if "Statement Templ. Name Coeff." <> xRec."Statement Templ. Name Coeff." then
                    Validate("Statement Name Coeff.", '');
            end;
        }
        field(11763; "Statement Name Coeff."; Code[10])
        {
            Caption = 'Statement Name Coeff.';
            TableRelation = "VAT Statement Name".Name WHERE("Statement Template Name" = FIELD("Statement Templ. Name Coeff."));
            ObsoleteState = Pending;
            ObsoleteReason = 'The functionality of Non-deductible VAT will be removed and this field should not be used. (Obsolete::Removed in release 01.2021)';

            trigger OnValidate()
            begin
                if "Statement Name Coeff." <> xRec."Statement Name Coeff." then
                    Clear("Statement Line No. Coeff.");
            end;
        }
        field(11764; "Statement Line No. Coeff."; Integer)
        {
            Caption = 'Statement Line No. Coeff.';
            TableRelation = "VAT Statement Line"."Line No." WHERE("Statement Template Name" = FIELD("Statement Templ. Name Coeff."),
                                                                   "Statement Name" = FIELD("Statement Name Coeff."),
                                                                   "Line No." = FIELD("Statement Line No. Coeff."));
            ObsoleteState = Pending;
            ObsoleteReason = 'The functionality of Non-deductible VAT will be removed and this field should not be used. (Obsolete::Removed in release 01.2021)';
        }
        field(11765; "Round VAT Coeff."; Boolean)
        {
            Caption = 'Round VAT Coeff.';
            ObsoleteState = Pending;
            ObsoleteReason = 'The functionality will be removed and this field should not be used. (Obsolete::Removed in release 01.2021)';
        }
        field(11766; "VAT Coeff. Rounding Precision"; Decimal)
        {
            Caption = 'VAT Coeff. Rounding Precision';
            DecimalPlaces = 2 : 4;
            ObsoleteState = Pending;
            ObsoleteReason = 'The functionality will be removed and this field should not be used. (Obsolete::Removed in release 01.2021)';
        }
        field(11768; "Allow VAT Posting From"; Date)
        {
            Caption = 'Allow VAT Posting From';

            trigger OnValidate()
            begin
                TestField("Use VAT Date");
            end;
        }
        field(11769; "Allow VAT Posting To"; Date)
        {
            Caption = 'Allow VAT Posting To';

            trigger OnValidate()
            begin
                TestField("Use VAT Date");
            end;
        }
        field(11770; "Use VAT Date"; Boolean)
        {
            Caption = 'Use VAT Date';

            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                ServiceSetup: Record "Service Mgt. Setup";
                PurchSetup: Record "Purchases & Payables Setup";
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                case "Use VAT Date" of
                    true:
                        if ConfirmManagement.GetResponseOrDefault(
                            StrSubstNo(InitVATDateQst,
                                FieldCaption("Use VAT Date"),
                                GLEntry.FieldCaption("VAT Date"),
                                GLEntry.FieldCaption("Posting Date")), true)
                        then
                            InitVATDate
                        else
                            "Use VAT Date" := xRec."Use VAT Date";
                    false:
                        begin
                            GLEntry.Reset;
                            GLEntry.SetFilter("VAT Date", '>%1', 0D);
                            if GLEntry.FindFirst then
                                Error(Text018, FieldCaption("Use VAT Date"));
                            if ConfirmManagement.GetResponseOrDefault(DisableVATDateQst, false) then begin
                                "Allow VAT Posting From" := 0D;
                                "Allow VAT Posting To" := 0D;
                                if PurchSetup.Get then
                                    PurchSetup."Default VAT Date" := 0;
                                if SalesSetup.Get then begin
                                    SalesSetup."Credit Memo Confirmation" := false;
                                    SalesSetup."Default VAT Date" := 0;
                                end;
                                if ServiceSetup.Get then begin
                                    ServiceSetup."Credit Memo Confirmation" := false;
                                    ServiceSetup."Default VAT Date" := 0;
                                end;
                            end else
                                "Use VAT Date" := xRec."Use VAT Date";
                        end;
                end;
            end;
        }
        field(11771; "Check VAT Identifier"; Boolean)
        {
            Caption = 'Check VAT Identifier';
            ObsoleteState = Pending;
            ObsoleteReason = 'The enhanced functionality of VAT Identifier will be removed and this field should not be used. (Obsolete::Removed in release 01.2021)';
        }
        field(11772; "Check Posting Debit/Credit"; Boolean)
        {
            Caption = 'Check Posting Debit/Credit';
        }
        field(11773; "Mark Neg. Qty as Correction"; Boolean)
        {
            Caption = 'Mark Neg. Qty as Correction';
        }
        field(11774; "Company Officials Nos."; Code[20])
        {
            Caption = 'Company Officials Nos.';
            TableRelation = "No. Series";
        }
        field(11775; "Correction As Storno"; Boolean)
        {
            Caption = 'Correction As Storno';
        }
        field(11776; "Dont Check Dimension"; Boolean)
        {
            Caption = 'Dont Check Dimension';
        }
        field(11790; "User Checks Allowed"; Boolean)
        {
            Caption = 'User Checks Allowed';

            trigger OnValidate()
            begin
                if "User Checks Allowed" then
                    UserSetupMgt.UserCheckAllowed;
            end;
        }
        field(11791; "User ID Lookup only User Check"; Boolean)
        {
            Caption = 'User ID Lookup only User Check';

            trigger OnValidate()
            begin
                if "User ID Lookup only User Check" then
                    UserSetupMgt.UserCheckAllowed;
            end;
        }
        field(11792; "Delete Card with Entries"; Boolean)
        {
            Caption = 'Delete Card with Entries';
            ObsoleteState = Pending;
            ObsoleteReason = 'The functionality of Disable Cards Deleting will be removed and this field should not be used. (Obsolete::Removed in release 01.2021)';
        }
        field(11793; "Reg. No. Validation URL"; Text[250])
        {
            Caption = 'Reg. No. Validation URL';
            ExtendedDatatype = URL;
            ObsoleteReason = 'This field has been replaced by Table 11757 Reg. No. Srv Config.';
            ObsoleteState = Removed;
        }
        field(31000; "Prepayment Type"; Option)
        {
            Caption = 'Prepayment Type';
            OptionCaption = ' ,Prepayments,Advances';
            OptionMembers = " ",Prepayments,Advances;
        }
        field(31002; "Use Adv. CM Nos for Adv. Corr."; Boolean)
        {
            Caption = 'Use Adv. CM Nos for Adv. Corr.';
        }
        field(31080; "Shared Account Schedule"; Code[10])
        {
            Caption = 'Shared Account Schedule';
            TableRelation = "Acc. Schedule Name";
        }
        field(31081; "Acc. Schedule Results Nos."; Code[20])
        {
            Caption = 'Acc. Schedule Results Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        Text000: Label '%1 %2 %3 have %4 to %5.';
        Text001: Label '%1 %2 have %3 to %4.';
        Text002: Label '%1 %2 %3 use %4.';
        Text003: Label '%1 %2 use %3.';
        Text004: Label '%1 must be rounded to the nearest %2.';
        Text016: Label 'Enter one number or two numbers separated by a colon. ';
        Text017: Label 'The online Help for this field describes how you can fill in the field.';
        Text018: Label 'You cannot change the contents of the %1 field because there are posted ledger entries.';
        Text021: Label 'You must close the program and start again in order to activate the amount-rounding feature.';
        Text022: Label 'You must close the program and start again in order to activate the unit-amount rounding feature.';
        Text023: Label '%1\You cannot use the same dimension twice in the same setup.';
        Dim: Record Dimension;
        GLEntry: Record "G/L Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
        JobLedgEntry: Record "Job Ledger Entry";
        ResLedgEntry: Record "Res. Ledger Entry";
        FALedgerEntry: Record "FA Ledger Entry";
        MaintenanceLedgerEntry: Record "Maintenance Ledger Entry";
        InsCoverageLedgerEntry: Record "Ins. Coverage Ledger Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        TaxJurisdiction: Record "Tax Jurisdiction";
        AnalysisView: Record "Analysis View";
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewBudgetEntry: Record "Analysis View Budget Entry";
        AdjAddReportingCurr: Report "Adjust Add. Reporting Currency";
        UserSetupManagement: Codeunit "User Setup Management";
        UserSetupMgt: Codeunit "User Setup Adv. Management";
        ErrorMessage: Boolean;
        DependentFieldActivatedErr: Label 'You cannot change %1 because %2 is selected.';
        Text025: Label 'The field %1 should not be set to %2 if field %3 in %4 table is set to %5 because deadlocks can occur.';
        DisableVATDateQst: Label 'Are you sure you want to disable VAT Date functionality?';
        InitVATDateQst: Label 'If you check field %1 you will let system post using %2 different from %3. Field %2 will be initialized from field %3 in all tables. It may take some time and you will not be able to undo this change after posting entries. Do you really want to continue?', Comment = '%1 = fieldcaption of Use VAT Date; %2 = fieldcaption of VAT Date; %3 = fieldcaption of Posting Date';
        ObsoleteErr: Label 'This field is obsolete, it has been replaced by Table 248 VAT Reg. No. Srv Config.';
        RecordHasBeenRead: Boolean;

    procedure CheckDecimalPlacesFormat(var DecimalPlaces: Text[5])
    var
        OK: Boolean;
        ColonPlace: Integer;
        DecimalPlacesPart1: Integer;
        DecimalPlacesPart2: Integer;
        Check: Text[5];
    begin
        OK := true;
        ColonPlace := StrPos(DecimalPlaces, ':');

        if ColonPlace = 0 then begin
            if not Evaluate(DecimalPlacesPart1, DecimalPlaces) then
                OK := false;
            if (DecimalPlacesPart1 < 0) or (DecimalPlacesPart1 > 9) then
                OK := false;
        end else begin
            Check := CopyStr(DecimalPlaces, 1, ColonPlace - 1);
            if Check = '' then
                OK := false;
            if not Evaluate(DecimalPlacesPart1, Check) then
                OK := false;
            Check := CopyStr(DecimalPlaces, ColonPlace + 1, StrLen(DecimalPlaces));
            if Check = '' then
                OK := false;
            if not Evaluate(DecimalPlacesPart2, Check) then
                OK := false;
            if DecimalPlacesPart1 > DecimalPlacesPart2 then
                OK := false;
            if (DecimalPlacesPart1 < 0) or (DecimalPlacesPart1 > 9) then
                OK := false;
            if (DecimalPlacesPart2 < 0) or (DecimalPlacesPart2 > 9) then
                OK := false;
        end;

        if not OK then
            Error(
              Text016 +
              Text017);

        if ColonPlace = 0 then
            DecimalPlaces := Format(DecimalPlacesPart1)
        else
            DecimalPlaces := StrSubstNo('%1:%2', DecimalPlacesPart1, DecimalPlacesPart2);
    end;

    procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    begin
        case CurrencyCode of
            '':
                exit("LCY Code");
            "LCY Code":
                exit('');
            else
                exit(CurrencyCode);
        end;
    end;

    procedure GetCurrencySymbol(): Text[10]
    begin
        if "Local Currency Symbol" <> '' then
            exit("Local Currency Symbol");

        exit("LCY Code");
    end;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Get;
        RecordHasBeenRead := true;
    end;

    local procedure RoundingErrorCheck(NameOfField: Text[100])
    begin
        ErrorMessage := false;
        if GLEntry.FindFirst then
            ErrorMessage := true;
        if ItemLedgerEntry.FindFirst then
            ErrorMessage := true;
        if JobLedgEntry.FindFirst then
            ErrorMessage := true;
        if ResLedgEntry.FindFirst then
            ErrorMessage := true;
        if FALedgerEntry.FindFirst then
            ErrorMessage := true;
        if MaintenanceLedgerEntry.FindFirst then
            ErrorMessage := true;
        if InsCoverageLedgerEntry.FindFirst then
            ErrorMessage := true;
        if ErrorMessage then
            Error(
              Text018,
              NameOfField);
    end;

    local procedure DeleteIntrastatJnl()
    var
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
    begin
        IntrastatJnlBatch.SetRange(Reported, false);
        IntrastatJnlBatch.SetRange("Amounts in Add. Currency", true);
        if IntrastatJnlBatch.Find('-') then
            repeat
                IntrastatJnlLine.SetRange("Journal Template Name", IntrastatJnlBatch."Journal Template Name");
                IntrastatJnlLine.SetRange("Journal Batch Name", IntrastatJnlBatch.Name);
                IntrastatJnlLine.DeleteAll;
            until IntrastatJnlBatch.Next = 0;
    end;

    local procedure DeleteAnalysisView()
    begin
        if AnalysisView.Find('-') then
            repeat
                if AnalysisView.Blocked = false then begin
                    AnalysisViewEntry.SetRange("Analysis View Code", AnalysisView.Code);
                    AnalysisViewEntry.DeleteAll;
                    AnalysisViewBudgetEntry.SetRange("Analysis View Code", AnalysisView.Code);
                    AnalysisViewBudgetEntry.DeleteAll;
                    AnalysisView."Last Entry No." := 0;
                    AnalysisView."Last Budget Entry No." := 0;
                    AnalysisView."Last Date Updated" := 0D;
                    AnalysisView.Modify;
                end else begin
                    AnalysisView."Refresh When Unblocked" := true;
                    AnalysisView.Modify;
                end;
            until AnalysisView.Next = 0;
    end;

    procedure IsPostingAllowed(PostingDate: Date): Boolean
    begin
        exit(PostingDate >= "Allow Posting From");
    end;

    procedure JobQueueActive(): Boolean
    begin
        Get;
        exit("Post with Job Queue" or "Post & Print with Job Queue");
    end;

    procedure OptimGLEntLockForMultiuserEnv(): Boolean
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if "Use Legacy G/L Entry Locking" then
            exit(false);

        if InventorySetup.Get then
            if InventorySetup."Automatic Cost Posting" then
                exit(false);

        exit(true);
    end;

    procedure FirstAllowedPostingDate() AllowedPostingDate: Date
    var
        InvtPeriod: Record "Inventory Period";
    begin
        AllowedPostingDate := "Allow Posting From";
        if not InvtPeriod.IsValidDate(AllowedPostingDate) then
            AllowedPostingDate := CalcDate('<+1D>', AllowedPostingDate);
    end;

    procedure UpdateDimValueGlobalDimNo(xDimCode: Code[20]; DimCode: Code[20]; ShortcutDimNo: Integer)
    var
        DimensionValue: Record "Dimension Value";
    begin
        if Dim.CheckIfDimUsed(DimCode, ShortcutDimNo, '', '', 0) then
            Error(Text023, Dim.GetCheckDimErr);
        if xDimCode <> '' then begin
            DimensionValue.SetRange("Dimension Code", xDimCode);
            DimensionValue.ModifyAll("Global Dimension No.", 0);
        end;
        if DimCode <> '' then begin
            DimensionValue.SetRange("Dimension Code", DimCode);
            DimensionValue.ModifyAll("Global Dimension No.", ShortcutDimNo);
        end;
        Modify;
    end;

    local procedure HideDialog(): Boolean
    begin
        exit((CurrFieldNo = 0) or not GuiAllowed);
    end;

    [Scope('OnPrem')]
    procedure InitVATDate()
    begin
        // NAVCZ
        InitVATDateFromRecord(DATABASE::"G/L Entry");
        InitVATDateFromRecord(DATABASE::"Gen. Journal Line");
        InitVATDateFromRecord(DATABASE::"VAT Entry");
        InitVATDateFromRecord(DATABASE::"Sales Header");
        InitVATDateFromRecord(DATABASE::"Sales Invoice Header");
        InitVATDateFromRecord(DATABASE::"Sales Cr.Memo Header");
        InitVATDateFromRecord(DATABASE::"Sales Header Archive");
        InitVATDateFromRecord(DATABASE::"Purchase Header");
        InitVATDateFromRecord(DATABASE::"Purch. Inv. Header");
        InitVATDateFromRecord(DATABASE::"Purch. Cr. Memo Hdr.");
        InitVATDateFromRecord(DATABASE::"Purchase Header Archive");
        InitVATDateFromRecord(DATABASE::"Service Header");
        InitVATDateFromRecord(DATABASE::"Service Invoice Header");
        InitVATDateFromRecord(DATABASE::"Service Cr.Memo Header");
        InitVATDateFromRecord(DATABASE::"Cust. Ledger Entry");
        InitVATDateFromRecord(DATABASE::"Vendor Ledger Entry");
        InitVATDateFromRecord(DATABASE::"Cash Document Header");
        InitVATDateFromRecord(DATABASE::"Posted Cash Document Header");
        InitVATDateFromRecord(DATABASE::"Sales Advance Letter Header");
        InitVATDateFromRecord(DATABASE::"Sales Advance Letter Entry");
        InitVATDateFromRecord(DATABASE::"Purch. Advance Letter Header");
        InitVATDateFromRecord(DATABASE::"Purch. Advance Letter Entry");
        InitVATDateFromRecord(DATABASE::"VAT Control Report Line");
    end;

    local procedure InitVATDateFromRecord(TableNo: Integer)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        PostingDateFieldRef: FieldRef;
        VATDateFieldRef: FieldRef;
    begin
        // NAVCZ
        RecRef.Open(TableNo);
        DataTypeManagement.FindFieldByName(RecRef, VATDateFieldRef, 'VAT Date');
        DataTypeManagement.FindFieldByName(RecRef, PostingDateFieldRef, 'Posting Date');
        VATDateFieldRef.SetRange(0D);
        PostingDateFieldRef.SetFilter('<>%1', 0D);
        if RecRef.FindSet(true) then
            repeat
                VATDateFieldRef.Value := PostingDateFieldRef.Value;
                RecRef.Modify;
            until RecRef.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure GetRoundingParamenters(var Currency: Record Currency; var RoundingPrecision: Decimal; var RoundingDirection: Text[1])
    begin
        // NAVCZ
        if Currency.Code <> '' then begin
            RoundingPrecision := Currency."Amount Rounding Precision";
            RoundingDirection := Currency.VATRoundingDirection;
        end else
            GetRoundingParamentersLCY(Currency, RoundingPrecision, RoundingDirection);
    end;

    [Scope('OnPrem')]
    procedure GetRoundingParamentersLCY(var Currency: Record Currency; var RoundingPrecision: Decimal; var RoundingDirection: Text[1])
    begin
        // NAVCZ
        RoundingPrecision := Currency."Amount Rounding Precision";
        RoundingDirection := Currency.VATRoundingDirection;
    end;

    procedure UseVat(): Boolean
    var
        GeneralLedgerSetupRecordRef: RecordRef;
        UseVATFieldRef: FieldRef;
        UseVATFieldNo: Integer;
    begin
        GeneralLedgerSetupRecordRef.Open(DATABASE::"General Ledger Setup", false);

        UseVATFieldNo := 10001;

        if not GeneralLedgerSetupRecordRef.FieldExist(UseVATFieldNo) then
            exit(true);

        if not GeneralLedgerSetupRecordRef.FindFirst then
            exit(false);

        UseVATFieldRef := GeneralLedgerSetupRecordRef.Field(UseVATFieldNo);
        exit(UseVATFieldRef.Value);
    end;

    procedure CheckAllowedPostingDates(NotificationType: Option Error,Notification)
    begin
        UserSetupManagement.CheckAllowedPostingDatesRange("Allow Posting From",
          "Allow Posting To", NotificationType, DATABASE::"General Ledger Setup");
    end;

    procedure GetPmtToleranceVisible(): Boolean
    begin
        exit(("Payment Tolerance %" > 0) or ("Max. Payment Tolerance Amount" <> 0));
    end;
}

