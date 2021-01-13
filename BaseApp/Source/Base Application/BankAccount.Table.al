table 270 "Bank Account"
{
    Caption = 'Bank Account';
    DataCaptionFields = "No.", Name;
    DrillDownPageID = "Bank Account List";
    LookupPageID = "Bank Account List";
    Permissions = TableData "Bank Account Ledger Entry" = r;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    GLSetup.Get;
                    NoSeriesMgt.TestManual(GetNoSeriesCode()); // NAVCZ
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
                    "Search Name" := Name;
            end;
        }
        field(3; "Search Name"; Code[100])
        {
            Caption = 'Search Name';
        }
        field(4; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(5; Address; Text[100])
        {
            Caption = 'Address';
        }
        field(6; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(7; City; Text[30])
        {
            Caption = 'City';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(8; Contact; Text[100])
        {
            Caption = 'Contact';
        }
        field(9; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(10; "Telex No."; Text[20])
        {
            Caption = 'Telex No.';
        }
        field(13; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                // NAVCZ
                CompanyInfo.Get;
                if ("Country/Region Code" = '') or (CompanyInfo."Country/Region Code" = "Country/Region Code") then
                    CompanyInfo.CheckCzBankAccountNo("Bank Account No.");
                // NAVCZ
            end;
        }
        field(14; "Transit No."; Text[20])
        {
            Caption = 'Transit No.';
        }
        field(15; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            TableRelation = Territory;
        }
        field(16; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Global Dimension 1 Code");
            end;
        }
        field(17; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Global Dimension 2 Code");
            end;
        }
        field(18; "Chain Name"; Code[10])
        {
            Caption = 'Chain Name';
        }
        field(20; "Min. Balance"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Min. Balance';
        }
        field(21; "Bank Acc. Posting Group"; Code[20])
        {
            Caption = 'Bank Acc. Posting Group';
            TableRelation = "Bank Account Posting Group";

            trigger OnValidate()
            begin
                // NAVCZ
                if "Bank Acc. Posting Group" <> xRec."Bank Acc. Posting Group" then
                    CheckOpenBankAccLedgerEntries;
                // NAVCZ
            end;
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                if "Currency Code" = xRec."Currency Code" then
                    exit;

                BankAcc.Reset;
                BankAcc := Rec;
                BankAcc.CalcFields(Balance, "Balance (LCY)");
                BankAcc.TestField(Balance, 0);
                BankAcc.TestField("Balance (LCY)", 0);
                BankAcc.TestZeroBalance; // NAVCZ
                if not BankAccLedgEntry.SetCurrentKey("Bank Account No.", Open) then
                    BankAccLedgEntry.SetCurrentKey("Bank Account No.");
                BankAccLedgEntry.SetRange("Bank Account No.", "No.");
                BankAccLedgEntry.SetRange(Open, true);
                if BankAccLedgEntry.FindLast then
                    Error(
                      Text000,
                      FieldCaption("Currency Code"));
                // NAVCZ
                if "Currency Code" = '' then
                    "Exclude from Exch. Rate Adj." := false;
                // NAVCZ
            end;
        }
        field(24; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(26; "Statistics Group"; Integer)
        {
            Caption = 'Statistics Group';
        }
        field(29; "Our Contact Code"; Code[20])
        {
            Caption = 'Our Contact Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(35; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                PostCode.CheckClearPostCodeCityCounty(City, "Post Code", County, "Country/Region Code", xRec."Country/Region Code");
            end;
        }
        field(37; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(38; Comment; Boolean)
        {
            CalcFormula = Exist ("Comment Line" WHERE("Table Name" = CONST("Bank Account"),
                                                      "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(39; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(41; "Last Statement No."; Code[20])
        {
            Caption = 'Last Statement No.';
        }
        field(42; "Last Payment Statement No."; Code[20])
        {
            Caption = 'Last Payment Statement No.';

            trigger OnValidate()
            begin
                if IncStr("Last Payment Statement No.") = '' then
                    Error(StrSubstNo(UnincrementableStringErr, FieldCaption("Last Payment Statement No.")));
            end;
        }
        field(54; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(55; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(56; "Global Dimension 1 Filter"; Code[20])
        {
            CaptionClass = '1,3,1';
            Caption = 'Global Dimension 1 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(57; "Global Dimension 2 Filter"; Code[20])
        {
            CaptionClass = '1,3,2';
            Caption = 'Global Dimension 2 Filter';
            FieldClass = FlowFilter;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(58; Balance; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum ("Bank Account Ledger Entry".Amount WHERE("Bank Account No." = FIELD("No."),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Balance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(59; "Balance (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Bank Account Ledger Entry"."Amount (LCY)" WHERE("Bank Account No." = FIELD("No."),
                                                                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter")));
            Caption = 'Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Net Change"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum ("Bank Account Ledger Entry".Amount WHERE("Bank Account No." = FIELD("No."),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                        "Posting Date" = FIELD("Date Filter")));
            Caption = 'Net Change';
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "Net Change (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Bank Account Ledger Entry"."Amount (LCY)" WHERE("Bank Account No." = FIELD("No."),
                                                                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Posting Date" = FIELD("Date Filter")));
            Caption = 'Net Change (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(62; "Total on Checks"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum ("Check Ledger Entry".Amount WHERE("Bank Account No." = FIELD("No."),
                                                                 "Entry Status" = FILTER(Posted),
                                                                 "Statement Status" = FILTER(<> Closed)));
            Caption = 'Total on Checks';
            Editable = false;
            FieldClass = FlowField;
        }
        field(84; "Fax No."; Text[30])
        {
            Caption = 'Fax No.';
        }
        field(85; "Telex Answer Back"; Text[20])
        {
            Caption = 'Telex Answer Back';
        }
        field(89; Picture; BLOB)
        {
            Caption = 'Picture';
            ObsoleteReason = 'Replaced by Image field';
            ObsoleteState = Pending;
            SubType = Bitmap;
            ObsoleteTag = '15.0';
        }
        field(91; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            begin
                PostCode.LookupPostCode(City, "Post Code", County, "Country/Region Code");
            end;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(92; County; Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
        }
        field(93; "Last Check No."; Code[20])
        {
            AccessByPermission = TableData "Check Ledger Entry" = R;
            Caption = 'Last Check No.';
        }
        field(94; "Balance Last Statement"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Balance Last Statement';
        }
        field(95; "Balance at Date"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum ("Bank Account Ledger Entry".Amount WHERE("Bank Account No." = FIELD("No."),
                                                                        "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                        "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                        "Posting Date" = FIELD(UPPERLIMIT("Date Filter"))));
            Caption = 'Balance at Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(96; "Balance at Date (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("Bank Account Ledger Entry"."Amount (LCY)" WHERE("Bank Account No." = FIELD("No."),
                                                                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Posting Date" = FIELD(UPPERLIMIT("Date Filter"))));
            Caption = 'Balance at Date (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(97; "Debit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("Bank Account Ledger Entry"."Debit Amount" WHERE("Bank Account No." = FIELD("No."),
                                                                                "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                "Posting Date" = FIELD("Date Filter")));
            Caption = 'Debit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(98; "Credit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("Bank Account Ledger Entry"."Credit Amount" WHERE("Bank Account No." = FIELD("No."),
                                                                                 "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                 "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                 "Posting Date" = FIELD("Date Filter")));
            Caption = 'Credit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(99; "Debit Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("Bank Account Ledger Entry"."Debit Amount (LCY)" WHERE("Bank Account No." = FIELD("No."),
                                                                                      "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                      "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                      "Posting Date" = FIELD("Date Filter")));
            Caption = 'Debit Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100; "Credit Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("Bank Account Ledger Entry"."Credit Amount (LCY)" WHERE("Bank Account No." = FIELD("No."),
                                                                                       "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"),
                                                                                       "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"),
                                                                                       "Posting Date" = FIELD("Date Filter")));
            Caption = 'Credit Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(101; "Bank Branch No."; Text[20])
        {
            Caption = 'Bank Branch No.';
        }
        field(102; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("E-Mail");
            end;
        }
        field(103; "Home Page"; Text[80])
        {
            Caption = 'Home Page';
            ExtendedDatatype = URL;
        }
        field(107; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(108; "Check Report ID"; Integer)
        {
            Caption = 'Check Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(109; "Check Report Name"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Name" WHERE("Object Type" = CONST(Report),
                                                                        "Object ID" = FIELD("Check Report ID")));
            Caption = 'Check Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110; IBAN; Code[50])
        {
            Caption = 'IBAN';

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                CompanyInfo.CheckIBAN(IBAN);
            end;
        }
        field(111; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
            TableRelation = "SWIFT Code";
            ValidateTableRelation = false;
        }
        field(113; "Bank Statement Import Format"; Code[20])
        {
            Caption = 'Bank Statement Import Format';
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST(Import));
        }
        field(115; "Credit Transfer Msg. Nos."; Code[20])
        {
            Caption = 'Credit Transfer Msg. Nos.';
            TableRelation = "No. Series";
        }
        field(116; "Direct Debit Msg. Nos."; Code[20])
        {
            Caption = 'Direct Debit Msg. Nos.';
            TableRelation = "No. Series";
        }
        field(117; "SEPA Direct Debit Exp. Format"; Code[20])
        {
            Caption = 'SEPA Direct Debit Exp. Format';
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST(Export));
        }
        field(121; "Bank Stmt. Service Record ID"; RecordID)
        {
            Caption = 'Bank Stmt. Service Record ID';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                Handled: Boolean;
            begin
                if Format("Bank Stmt. Service Record ID") = '' then
                    OnUnlinkStatementProviderEvent(Rec, Handled);
            end;
        }
        field(123; "Transaction Import Timespan"; Integer)
        {
            Caption = 'Transaction Import Timespan';
        }
        field(124; "Automatic Stmt. Import Enabled"; Boolean)
        {
            Caption = 'Automatic Stmt. Import Enabled';

            trigger OnValidate()
            begin
                if "Automatic Stmt. Import Enabled" then begin
                    if not IsAutoLogonPossible then
                        Error(MFANotSupportedErr);

                    if not ("Transaction Import Timespan" in [0 .. 9999]) then
                        Error(TransactionImportTimespanMustBePositiveErr);
                    ScheduleBankStatementDownload
                end else
                    UnscheduleBankStatementDownload;
            end;
        }
        field(140; Image; Media)
        {
            Caption = 'Image';
        }
        field(170; "Creditor No."; Code[35])
        {
            Caption = 'Creditor No.';
        }
        field(1210; "Payment Export Format"; Code[20])
        {
            Caption = 'Payment Export Format';
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST(Export));
        }
        field(1211; "Bank Clearing Code"; Text[50])
        {
            Caption = 'Bank Clearing Code';
        }
        field(1212; "Bank Clearing Standard"; Text[50])
        {
            Caption = 'Bank Clearing Standard';
            TableRelation = "Bank Clearing Standard";
        }
        field(1213; "Bank Name - Data Conversion"; Text[50])
        {
            Caption = 'Bank Name - Data Conversion';
            ObsoleteState = Removed;
            ObsoleteReason = 'Changed to AMC Banking 365 Fundamentals Extension';
            ObsoleteTag = '15.0';
        }
        field(1250; "Match Tolerance Type"; Option)
        {
            Caption = 'Match Tolerance Type';
            OptionCaption = 'Percentage,Amount';
            OptionMembers = Percentage,Amount;

            trigger OnValidate()
            begin
                if "Match Tolerance Type" <> xRec."Match Tolerance Type" then
                    "Match Tolerance Value" := 0;
            end;
        }
        field(1251; "Match Tolerance Value"; Decimal)
        {
            Caption = 'Match Tolerance Value';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if "Match Tolerance Value" < 0 then
                    Error(InvalidValueErr);

                if "Match Tolerance Type" = "Match Tolerance Type"::Percentage then
                    if "Match Tolerance Value" > 99 then
                        Error(InvalidPercentageValueErr, FieldCaption("Match Tolerance Type"),
                          Format("Match Tolerance Type"::Percentage));
            end;
        }
        field(1260; "Positive Pay Export Code"; Code[20])
        {
            Caption = 'Positive Pay Export Code';
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST("Export-Positive Pay"));
        }
        field(11700; "Default Constant Symbol"; Code[10])
        {
            Caption = 'Default Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol";
        }
        field(11701; "Default Specific Symbol"; Code[10])
        {
            Caption = 'Default Specific Symbol';
            CharAllowed = '09';
        }
        field(11703; "Specific Symbol"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
        }
        field(11705; "Domestic Payment Order"; Integer)
        {
            BlankZero = true;
            Caption = 'Domestic Payment Order';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(11706; "Foreign Payment Order"; Integer)
        {
            BlankZero = true;
            Caption = 'Foreign Payment Order';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(11707; "Bank Pmt. Appl. Rule Code"; Code[10])
        {
            Caption = 'Bank Pmt. Appl. Rule Code';
            TableRelation = "Bank Pmt. Appl. Rule Code";
        }
        field(11708; "Text-to-Account Mapping Code"; Code[10])
        {
            Caption = 'Text-to-Account Mapping Code';
            TableRelation = "Text-to-Account Mapping Code";
        }
        field(11710; "Dimension from Apply Entry"; Boolean)
        {
            Caption = 'Dimension from Apply Entry';
        }
        field(11711; "Check Ext. No. by Current Year"; Boolean)
        {
            Caption = 'Check Ext. No. by Current Year';
        }
        field(11712; "Check Czech Format on Issue"; Boolean)
        {
            Caption = 'Check Czech Format on Issue';
        }
        field(11713; "Variable S. to Description"; Boolean)
        {
            Caption = 'Variable S. to Description';
        }
        field(11714; "Variable S. to Variable S."; Boolean)
        {
            Caption = 'Variable S. to Variable S.';
        }
        field(11715; "Variable S. to Ext. Doc.No."; Boolean)
        {
            Caption = 'Variable S. to Ext. Doc.No.';
        }
        field(11716; "Foreign Payment Orders"; Boolean)
        {
            Caption = 'Foreign Payment Orders';
        }
        field(11717; "Post Per Line"; Boolean)
        {
            Caption = 'Post Per Line';
            InitValue = true;
        }
        field(11718; "Payment Partial Suggestion"; Boolean)
        {
            Caption = 'Payment Partial Suggestion';
        }
        field(11720; "Payment Order Line Description"; Text[50])
        {
            Caption = 'Payment Order Line Description';
        }
        field(11721; "Non Associated Payment Account"; Code[20])
        {
            Caption = 'Non Associated Payment Account';
            TableRelation = "G/L Account";
        }
        field(11722; "Base Calendar Code"; Code[10])
        {
            Caption = 'Base Calendar Code';
            TableRelation = "Base Calendar";
        }
        field(11723; "Payment Jnl. Template Name"; Code[10])
        {
            Caption = 'Payment Jnl. Template Name';
            TableRelation = "Gen. Journal Template" WHERE(Type = CONST(Payments));

            trigger OnValidate()
            begin
                // NAVCZ
                if "Payment Jnl. Template Name" <> xRec."Payment Jnl. Template Name" then
                    "Payment Jnl. Batch Name" := '';
                // NAVCZ
            end;
        }
        field(11724; "Payment Jnl. Batch Name"; Code[10])
        {
            Caption = 'Payment Jnl. Batch Name';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Payment Jnl. Template Name"),
                                                             "Bal. Account Type" = CONST("Bank Account"),
                                                             "Bal. Account No." = FIELD("No."),
                                                             "Allow Payment Export" = CONST(true));
        }
        field(11725; "Payment Order Nos."; Code[20])
        {
            Caption = 'Payment Order Nos.';
            TableRelation = "No. Series";
        }
        field(11726; "Issued Payment Order Nos."; Code[20])
        {
            Caption = 'Issued Payment Order Nos.';
            TableRelation = "No. Series";
        }
        field(11727; "Bank Statement Nos."; Code[20])
        {
            Caption = 'Bank Statement Nos.';
            TableRelation = "No. Series";
        }
        field(11728; "Issued Bank Statement Nos."; Code[20])
        {
            Caption = 'Issued Bank Statement Nos.';
            TableRelation = "No. Series";
        }
        field(11730; "Max. Balance Checking"; Option)
        {
            Caption = 'Max. Balance Checking';
            OptionCaption = 'No Checking,Warning,Blocking';
            OptionMembers = "No Checking",Warning,Blocking;
        }
        field(11731; "Min. Balance Checking"; Option)
        {
            Caption = 'Min. Balance Checking';
            OptionCaption = 'No Checking,Warning,Blocking';
            OptionMembers = "No Checking",Warning,Blocking;
        }
        field(11732; "Allow VAT Difference"; Boolean)
        {
            Caption = 'Allow VAT Difference';
        }
        field(11733; "Payed To/By Checking"; Option)
        {
            Caption = 'Payed To/By Checking';
            OptionCaption = 'No Checking,Warning,Blocking';
            OptionMembers = "No Checking",Warning,Blocking;
        }
        field(11734; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(11735; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(11736; "Amounts Including VAT"; Boolean)
        {
            Caption = 'Amounts Including VAT';
        }
        field(11737; "Confirm Inserting of Document"; Boolean)
        {
            Caption = 'Confirm Inserting of Document';
        }
        field(11738; "Debit Rounding Account"; Code[20])
        {
            Caption = 'Debit Rounding Account';
            TableRelation = "G/L Account"."No." WHERE("Account Type" = CONST(Posting));
        }
        field(11739; "Credit Rounding Account"; Code[20])
        {
            Caption = 'Credit Rounding Account';
            TableRelation = "G/L Account"."No." WHERE("Account Type" = CONST(Posting));
        }
        field(11740; "Rounding Method Code"; Code[10])
        {
            Caption = 'Rounding Method Code';
            TableRelation = "Rounding Method";
        }
        field(11741; "Responsibility ID (Release)"; Code[50])
        {
            Caption = 'Responsibility ID (Release)';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(11742; "Responsibility ID (Post)"; Code[50])
        {
            Caption = 'Responsibility ID (Post)';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(11743; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(11760; "Amount Rounding Precision"; Decimal)
        {
            Caption = 'Amount Rounding Precision';
            DecimalPlaces = 2 : 5;
            InitValue = 1;
            MinValue = 0;
        }
        field(11761; "CashReg Document Copies"; Integer)
        {
            Caption = 'CashReg Document Copies';
        }
        field(11762; "Direct Posting"; Boolean)
        {
            Caption = 'Direct Posting';
        }
        field(11763; "Account Type"; Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'Bank Account,Cash Desk';
            OptionMembers = "Bank Account","Cash Desk";
        }
        field(11764; "Max. Balance"; Decimal)
        {
            Caption = 'Max. Balance';
        }
        field(11765; "Cash Document Receipt Nos."; Code[20])
        {
            Caption = 'Cash Document Receipt Nos.';
            TableRelation = "No. Series";
        }
        field(11766; "Cash Document Withdrawal Nos."; Code[20])
        {
            Caption = 'Cash Document Withdrawal Nos.';
            TableRelation = "No. Series";
        }
        field(11767; "Cash Receipt Limit"; Decimal)
        {
            Caption = 'Cash Receipt Limit';
        }
        field(11768; "Cash Withdrawal Limit"; Decimal)
        {
            Caption = 'Cash Withdrawal Limit';
        }
        field(11769; "Exclude from Exch. Rate Adj."; Boolean)
        {
            Caption = 'Exclude from Exch. Rate Adj.';

            trigger OnValidate()
            begin
                if "Exclude from Exch. Rate Adj." then begin
                    TestField("Currency Code");
                    if not Confirm(ExcludeEntriesQst) then
                        "Exclude from Exch. Rate Adj." := xRec."Exclude from Exch. Rate Adj."
                end;
            end;
        }
        field(11770; "Cashier No."; Code[20])
        {
            Caption = 'Cashier No.';
            TableRelation = Employee;
        }
        field(11779; "Run Apply Automatically"; Boolean)
        {
            Caption = 'Run Apply Automatically';
            InitValue = true;
        }
        field(11780; "Foreign Payment Export Format"; Code[20])
        {
            Caption = 'Foreign Payment Export Format';
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST(Export));
        }
        field(11781; "Payment Import Format"; Code[20])
        {
            Caption = 'Payment Import Format';
            TableRelation = "Bank Export/Import Setup".Code WHERE(Direction = CONST(Import));
        }
        field(11782; "Not Apply Cust. Ledger Entries"; Boolean)
        {
            Caption = 'Not Apply Cust. Ledger Entries';
        }
        field(11783; "Not Apply Vend. Ledger Entries"; Boolean)
        {
            Caption = 'Not Apply Vend. Ledger Entries';
        }
        field(11784; "Not Apply Sales Advances"; Boolean)
        {
            Caption = 'Not Apply Sales Advances';
        }
        field(11785; "Not Apply Purchase Advances"; Boolean)
        {
            Caption = 'Not Apply Purchase Advances';
        }
        field(11786; "Not Apply Gen. Ledger Entries"; Boolean)
        {
            Caption = 'Not Apply Gen. Ledger Entries';
            InitValue = true;
        }
        field(11787; "Not Apl. Bank Acc.Ledg.Entries"; Boolean)
        {
            Caption = 'Not Apl. Bank Acc.Ledg.Entries';
        }
        field(11788; "Copy VAT Setup to Jnl. Line"; Boolean)
        {
            Caption = 'Copy VAT Setup to Jnl. Line';
        }
        field(31120; "EET Cash Register"; Boolean)
        {
            CalcFormula = Exist ("EET Cash Register" WHERE("Register Type" = CONST("Cash Desk"),
                                                           "Register No." = FIELD("No.")));
            Caption = 'EET Cash Register';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Search Name")
        {
        }
        key(Key3; "Bank Acc. Posting Group")
        {
        }
        key(Key4; "Currency Code")
        {
        }
        key(Key5; "Country/Region Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Name, "Bank Account No.", "Currency Code")
        {
        }
        fieldgroup(Brick; "No.", Name, "Bank Account No.", "Currency Code", Image)
        {
        }
    }

    trigger OnDelete()
    var
        CashDocHdr: Record "Cash Document Header";
        CashDeskUser: Record "Cash Desk User";
        CashDeskEvent: Record "Cash Desk Event";
    begin
        CheckDeleteBalancingBankAccount;

        MoveEntries.MoveBankAccEntries(Rec);

        CommentLine.SetRange("Table Name", CommentLine."Table Name"::"Bank Account");
        CommentLine.SetRange("No.", "No.");
        CommentLine.DeleteAll;

        UpdateContFromBank.OnDelete(Rec);

        DimMgt.DeleteDefaultDim(DATABASE::"Bank Account", "No.");

        // NAVCZ
        if "Account Type" = "Account Type"::"Cash Desk" then begin
            CashDocHdr.SetRange("Cash Desk No.", "No.");
            if not CashDocHdr.IsEmpty then
                Error(CannotDeleteErr, "Account Type", "No.", CashDocHdr.TableCaption);
            CashDeskUser.SetRange("Cash Desk No.", "No.");
            CashDeskUser.DeleteAll;
            CashDeskEvent.SetRange("Cash Desk No.", "No.");
            CashDeskEvent.DeleteAll;
        end;
        // NAVCZ
    end;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            // NAVCZ
            TestNoSeries();
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xRec."No. Series", 0D, "No.", "No. Series");
            // NAVCZ
        end;

        if "Account Type" <> "Account Type"::"Cash Desk" then // NAVCZ
            if not InsertFromContact then
                UpdateContFromBank.OnInsert(Rec);

        DimMgt.UpdateDefaultDim(
          DATABASE::"Bank Account", "No.",
          "Global Dimension 1 Code", "Global Dimension 2 Code");
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today;

        if IsContactUpdateNeeded then begin
            Modify;
            UpdateContFromBank.OnModify(Rec);
            if not Find then begin
                Reset;
                if Find then;
            end;
        end;
    end;

    trigger OnRename()
    begin
        DimMgt.RenameDefaultDim(DATABASE::"Bank Account", xRec."No.", "No.");
        "Last Date Modified" := Today;
    end;

    var
        Text000: Label 'You cannot change %1 because there are one or more open ledger entries for this bank account.';
        Text003: Label 'Do you wish to create a contact for %1 %2?';
        GLSetup: Record "General Ledger Setup";
        BankAcc: Record "Bank Account";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        CommentLine: Record "Comment Line";
        PostCode: Record "Post Code";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        MoveEntries: Codeunit MoveEntries;
        UpdateContFromBank: Codeunit "BankCont-Update";
        DimMgt: Codeunit DimensionManagement;
        CashDeskMgt: Codeunit CashDeskManagement;
        InsertFromContact: Boolean;
        Text004: Label 'Before you can use Online Map, you must fill in the Online Map Setup window.\See Setting Up Online Map in Help.';
        ExcludeEntriesQst: Label 'All entries will be excluded from Exchange Rates Adjustment. Do you want to continue?';
        CannotDeleteErr: Label 'You cannot delete %1 %2, beacause %3 exist.', Comment = '%1 = account type, %2 = number, %3 = tablecaption';
        BankAccIdentifierIsEmptyErr: Label 'You must specify either a %1 or an %2.';
        InvalidPercentageValueErr: Label 'If %1 is %2, then the value must be between 0 and 99.', Comment = '%1 is "field caption and %2 is "Percentage"';
        InvalidValueErr: Label 'The value must be positive.';
        DataExchNotSetErr: Label 'The Data Exchange Code field must be filled.';
        BankStmtScheduledDownloadDescTxt: Label '%1 Bank Statement Import', Comment = '%1 - Bank Account name';
        JobQEntriesCreatedQst: Label 'A job queue entry for import of bank statements has been created.\\Do you want to open the Job Queue Entry window?';
        TransactionImportTimespanMustBePositiveErr: Label 'The value in the Number of Days Included field must be a positive number not greater than 9999.';
        MFANotSupportedErr: Label 'Cannot setup automatic bank statement import because the selected bank requires multi-factor authentication.';
        BankAccNotLinkedErr: Label 'This bank account is not linked to an online bank account.';
        AutoLogonNotPossibleErr: Label 'Automatic logon is not possible for this bank account.';
        CancelTxt: Label 'Cancel';
        OnlineFeedStatementStatus: Option "Not Linked",Linked,"Linked and Auto. Bank Statement Enabled";
        UnincrementableStringErr: Label 'The value in the %1 field must have a number so that we can assign the next number in the series.', Comment = '%1 = caption of field (Last Payment Statement No.)';
        CannotDeleteBalancingBankAccountErr: Label 'You cannot delete bank account that is used as balancing account in the Payment Registration Setup.', Locked = true;
        ConfirmDeleteBalancingBankAccountQst: Label 'This bank account is used as balancing account on the Payment Registration Setup page.\\Are you sure you want to delete it?';
        CurrExchRateIsEmptyErr: Label 'There is no Currency Exchange Rate within the filter. Filters: %1.', Comment = '%1 = filters';

    procedure AssistEdit(OldBankAcc: Record "Bank Account"): Boolean
    begin
        with BankAcc do begin
            BankAcc := Rec;
            TestNoSeries(); // NAVCZ
            if NoSeriesMgt.SelectSeries(GetNoSeriesCode(), OldBankAcc."No. Series", "No. Series") then begin // NAVCZ
                NoSeriesMgt.SetSeries("No.");
                Rec := BankAcc;
                exit(true);
            end;
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        OnBeforeValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);

        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        if not IsTemporary then begin
            DimMgt.SaveDefaultDim(DATABASE::"Bank Account", "No.", FieldNumber, ShortcutDimCode);
            Modify;
        end;

        OnAfterValidateShortcutDimCode(Rec, xRec, FieldNumber, ShortcutDimCode);
    end;

    procedure ShowContact()
    var
        ContBusRel: Record "Contact Business Relation";
        Cont: Record Contact;
    begin
        if "No." = '' then
            exit;

        ContBusRel.SetCurrentKey("Link to Table", "No.");
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::"Bank Account");
        ContBusRel.SetRange("No.", "No.");
        if not ContBusRel.FindFirst then begin
            if not Confirm(Text003, false, TableCaption, "No.") then
                exit;
            UpdateContFromBank.InsertNewContact(Rec, false);
            ContBusRel.FindFirst;
        end;
        Commit;

        Cont.FilterGroup(2);
        Cont.SetCurrentKey("Company Name", "Company No.", Type, Name);
        Cont.SetRange("Company No.", ContBusRel."Contact No.");
        PAGE.Run(PAGE::"Contact List", Cont);
    end;

    procedure SetInsertFromContact(FromContact: Boolean)
    begin
        InsertFromContact := FromContact;
    end;

    procedure GetPaymentExportCodeunitID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        GetBankExportImportSetup(BankExportImportSetup);
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    procedure GetPaymentExportXMLPortID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        GetBankExportImportSetup(BankExportImportSetup);
        BankExportImportSetup.TestField("Processing XMLport ID");
        exit(BankExportImportSetup."Processing XMLport ID");
    end;

    procedure GetDDExportCodeunitID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        GetDDExportImportSetup(BankExportImportSetup);
        BankExportImportSetup.TestField("Processing Codeunit ID");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    procedure GetDDExportXMLPortID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        GetDDExportImportSetup(BankExportImportSetup);
        BankExportImportSetup.TestField("Processing XMLport ID");
        exit(BankExportImportSetup."Processing XMLport ID");
    end;

    procedure GetBankExportImportSetup(var BankExportImportSetup: Record "Bank Export/Import Setup")
    begin
        TestField("Payment Export Format");
        BankExportImportSetup.Get("Payment Export Format");
    end;

    procedure GetDDExportImportSetup(var BankExportImportSetup: Record "Bank Export/Import Setup")
    begin
        TestField("SEPA Direct Debit Exp. Format");
        BankExportImportSetup.Get("SEPA Direct Debit Exp. Format");
    end;

    procedure GetCreditTransferMessageNo(): Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        TestField("Credit Transfer Msg. Nos.");
        exit(NoSeriesManagement.GetNextNo("Credit Transfer Msg. Nos.", Today, true));
    end;

    procedure GetDirectDebitMessageNo(): Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        TestField("Direct Debit Msg. Nos.");
        exit(NoSeriesManagement.GetNextNo("Direct Debit Msg. Nos.", Today, true));
    end;

    procedure DisplayMap()
    var
        MapPoint: Record "Online Map Setup";
        MapMgt: Codeunit "Online Map Management";
    begin
        if MapPoint.FindFirst then
            MapMgt.MakeSelection(DATABASE::"Bank Account", GetPosition)
        else
            Message(Text004);
    end;

    procedure GetDataExchDef(var DataExchDef: Record "Data Exch. Def")
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        DataExchDefCodeResponse: Code[20];
        Handled: Boolean;
    begin
        OnGetDataExchangeDefinitionEvent(DataExchDefCodeResponse, Handled);
        if not Handled then begin
            TestField("Bank Statement Import Format");
            DataExchDefCodeResponse := "Bank Statement Import Format";
        end;

        if DataExchDefCodeResponse = '' then
            Error(DataExchNotSetErr);

        BankExportImportSetup.Get(DataExchDefCodeResponse);
        BankExportImportSetup.TestField("Data Exch. Def. Code");

        DataExchDef.Get(BankExportImportSetup."Data Exch. Def. Code");
        DataExchDef.TestField(Type, DataExchDef.Type::"Bank Statement Import");
    end;

    procedure GetDataExchDefPaymentExport(var DataExchDef: Record "Data Exch. Def")
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        TestField("Payment Export Format");
        BankExportImportSetup.Get("Payment Export Format");
        BankExportImportSetup.TestField("Data Exch. Def. Code");
        DataExchDef.Get(BankExportImportSetup."Data Exch. Def. Code");
        DataExchDef.TestField(Type, DataExchDef.Type::"Payment Export");
    end;

    procedure GetDataExchDefForeignPaymentExport(var DataExchDef: Record "Data Exch. Def")
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        // NAVCZ
        TestField("Foreign Payment Export Format");
        BankExportImportSetup.Get("Foreign Payment Export Format");
        BankExportImportSetup.TestField("Data Exch. Def. Code");
        DataExchDef.Get(BankExportImportSetup."Data Exch. Def. Code");
        DataExchDef.TestField(Type, DataExchDef.Type::"Payment Export");
    end;

    [Scope('OnPrem')]
    procedure TestZeroBalance()
    begin
        CalcFields(Balance, "Balance (LCY)");
        TestField(Balance, 0);
        TestField("Balance (LCY)", 0);
    end;

    local procedure CheckOpenBankAccLedgerEntries()
    var
        BankAccount: Record "Bank Account";
    begin
        // NAVCZ
        BankAccount.Get("No.");
        BankAccount.CalcFields(Balance, "Balance (LCY)");
        BankAccount.TestField(Balance, 0);
        BankAccount.TestField("Balance (LCY)", 0);
    end;

    [Scope('OnPrem')]
    [Obsolete('Replaced by functions TestNoSeries and GetNoSeriesCode', '15.3')]
    procedure GetAccountNos(): Code[20]
    begin
        // NAVCZ
        TestNoSeries();
        exit(GetNoSeriesCode());
    end;

    procedure TestNoSeries()
    begin
        // NAVCZ
        GLSetup.Get;
        case "Account Type" of
            "Account Type"::"Bank Account":
                GLSetup.TestField("Bank Account Nos.");
            "Account Type"::"Cash Desk":
                GLSetup.TestField("Cash Desk Nos.");
        end;
    end;

    procedure GetNoSeriesCode(): Code[20]
    begin
        // NAVCZ
        GLSetup.Get;
        case "Account Type" of
            "Account Type"::"Bank Account":
                exit(GLSetup."Bank Account Nos.");
            "Account Type"::"Cash Desk":
                exit(GLSetup."Cash Desk Nos.");
        end;
    end;

    [Scope('OnPrem')]
    procedure Lookup()
    var
        CashDeskList: Page "Cash Desk List";
        BankList: Page "Bank List";
    begin
        // NAVCZ
        case "Account Type" of
            "Account Type"::"Bank Account":
                begin
                    BankList.LookupMode(true);
                    BankList.SetRecord(Rec);
                    if BankList.RunModal = ACTION::LookupOK then
                        BankList.GetRecord(Rec);
                end;
            "Account Type"::"Cash Desk":
                begin
                    CashDeskList.LookupMode(true);
                    CashDeskList.SetRecord(Rec);
                    if CashDeskList.RunModal = ACTION::LookupOK then
                        CashDeskList.GetRecord(Rec);
                end;
        end;
    end;

    [Scope('OnPrem')]
    procedure CardPageRun()
    var
        BankAccount: Record "Bank Account";
        CashDesksFilter: Text;
    begin
        // NAVCZ
        BankAccount.Copy(Rec);
        case "Account Type" of
            "Account Type"::"Bank Account":
                PAGE.Run(PAGE::"Bank Account Card", BankAccount);
            "Account Type"::"Cash Desk":
                begin
                    CheckCashDesks;
                    CashDesksFilter := CashDeskMgt.GetCashDesksFilter;

                    BankAccount.FilterGroup(2);
                    if CashDesksFilter <> '' then
                        BankAccount.SetFilter("No.", CashDesksFilter);
                    BankAccount.FilterGroup(0);

                    PAGE.Run(PAGE::"Cash Desk Card", BankAccount);
                end;
        end;
    end;

    [Scope('OnPrem')]
    procedure CalcBalance(): Decimal
    begin
        // NAVCZ
        exit(CalcOpenedReceipts + CalcOpenedWithdrawals + CalcPostedReceipts + CalcPostedWithdrawals);
    end;

    [Scope('OnPrem')]
    procedure CalcOpenedWithdrawals(): Decimal
    var
        CashDocHeader: Record "Cash Document Header";
    begin
        // NAVCZ
        exit(CalcOpenedNetChanges(CashDocHeader."Cash Document Type"::Withdrawal));
    end;

    [Scope('OnPrem')]
    procedure CalcOpenedReceipts(): Decimal
    var
        CashDocHeader: Record "Cash Document Header";
    begin
        // NAVCZ
        exit(CalcOpenedNetChanges(CashDocHeader."Cash Document Type"::Receipt));
    end;

    local procedure CalcOpenedNetChanges(CashDocumentType: Option): Decimal
    var
        CashDocHeader: Record "Cash Document Header";
    begin
        // NAVCZ
        CopyFilter("Date Filter", CashDocHeader."Posting Date");
        CashDocHeader.SetRange("Cash Desk No.", "No.");
        CashDocHeader.SetRange("Cash Document Type", CashDocumentType);
        CashDocHeader.SetRange(Status, CashDocHeader.Status::Released);
        CashDocHeader.CalcSums("Released Amount");

        if CashDocumentType = CashDocHeader."Cash Document Type"::Withdrawal then
            exit(-CashDocHeader."Released Amount");

        exit(CashDocHeader."Released Amount");
    end;

    [Scope('OnPrem')]
    procedure CalcPostedWithdrawals(): Decimal
    var
        CashDocHeader: Record "Cash Document Header";
    begin
        // NAVCZ
        exit(CalcPostedNetChanges(CashDocHeader."Cash Document Type"::Withdrawal));
    end;

    [Scope('OnPrem')]
    procedure CalcPostedReceipts(): Decimal
    var
        CashDocHeader: Record "Cash Document Header";
    begin
        // NAVCZ
        exit(CalcPostedNetChanges(CashDocHeader."Cash Document Type"::Receipt));
    end;

    local procedure CalcPostedNetChanges(CashDocumentType: Option): Decimal
    var
        PostedCashDocLine: Record "Posted Cash Document Line";
        PostedCashDocHeader: Record "Posted Cash Document Header";
        TotalNetChange: Decimal;
    begin
        // NAVCZ
        if GetFilter("Date Filter") = '' then begin
            PostedCashDocLine.SetRange("Cash Desk No.", "No.");
            PostedCashDocLine.SetRange("Cash Document Type", CashDocumentType);
            PostedCashDocLine.CalcSums("Amount Including VAT");
            TotalNetChange += PostedCashDocLine."Amount Including VAT";
        end else begin
            CopyFilter("Date Filter", PostedCashDocHeader."Posting Date");
            PostedCashDocHeader.SetRange("Cash Desk No.", "No.");
            if PostedCashDocHeader.FindSet then
                repeat
                    PostedCashDocLine.SetRange("Cash Document No.", PostedCashDocHeader."No.");
                    PostedCashDocLine.SetRange("Cash Desk No.", "No.");
                    PostedCashDocLine.SetRange("Cash Document Type", CashDocumentType);
                    PostedCashDocLine.CalcSums("Amount Including VAT");
                    TotalNetChange += PostedCashDocLine."Amount Including VAT";
                until PostedCashDocHeader.Next = 0;
        end;

        if CashDocumentType = PostedCashDocHeader."Cash Document Type"::Withdrawal then
            exit(-TotalNetChange);

        exit(TotalNetChange);
    end;

    procedure GetBankAccountNoWithCheck() AccountNo: Text
    begin
        AccountNo := GetBankAccountNo;
        if AccountNo = '' then
            Error(BankAccIdentifierIsEmptyErr, FieldCaption("Bank Account No."), FieldCaption(IBAN));
    end;

    procedure GetBankAccountNo(): Text
    begin
        if IBAN <> '' then
            exit(DelChr(IBAN, '=<>'));

        if "Bank Account No." <> '' then
            exit("Bank Account No.");
    end;

    procedure IsInLocalCurrency(): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if "Currency Code" = '' then
            exit(true);

        GeneralLedgerSetup.Get;
        exit("Currency Code" = GeneralLedgerSetup.GetCurrencyCode(''));
    end;

    procedure GetPosPayExportCodeunitID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        TestField("Positive Pay Export Code");
        BankExportImportSetup.Get("Positive Pay Export Code");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    [Scope('OnPrem')]
    procedure GetForeignPaymentExportCodeunitID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        // NAVCZ
        TestField("Foreign Payment Export Format");
        BankExportImportSetup.Get("Foreign Payment Export Format");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    [Scope('OnPrem')]
    procedure GetPaymentImportCodeunitID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        // NAVCZ
        TestField("Payment Import Format");
        BankExportImportSetup.Get("Payment Import Format");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    [Scope('OnPrem')]
    procedure GetBankStatementImportCodeunitID(): Integer
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        // NAVCZ
        TestField("Bank Statement Import Format");
        BankExportImportSetup.Get("Bank Statement Import Format");
        exit(BankExportImportSetup."Processing Codeunit ID");
    end;

    procedure CheckCurrExchRateExist(Date: Date)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        // NAVCZ
        if IsInLocalCurrency() then
            exit;

        CurrExchRate.SetRange("Currency Code", "Currency Code");
        CurrExchRate.SetRange("Starting Date", 0D, Date);
        if CurrExchRate.IsEmpty() then
            Error(CurrExchRateIsEmptyErr, CurrExchRate.GetFilters());
    end;

    procedure IsLinkedToBankStatementServiceProvider(): Boolean
    var
        IsBankAccountLinked: Boolean;
    begin
        OnCheckLinkedToStatementProviderEvent(Rec, IsBankAccountLinked);
        exit(IsBankAccountLinked);
    end;

    procedure StatementProvidersExist(): Boolean
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
    begin
        OnGetStatementProvidersEvent(TempNameValueBuffer);
        exit(not TempNameValueBuffer.IsEmpty);
    end;

    procedure LinkStatementProvider(var BankAccount: Record "Bank Account")
    var
        StatementProvider: Text;
    begin
        StatementProvider := SelectBankLinkingService;

        if StatementProvider <> '' then
            OnLinkStatementProviderEvent(BankAccount, StatementProvider);
    end;

    procedure SimpleLinkStatementProvider(var OnlineBankAccLink: Record "Online Bank Acc. Link")
    var
        StatementProvider: Text;
    begin
        StatementProvider := SelectBankLinkingService;

        if StatementProvider <> '' then
            OnSimpleLinkStatementProviderEvent(OnlineBankAccLink, StatementProvider);
    end;

    procedure UnlinkStatementProvider()
    var
        Handled: Boolean;
    begin
        OnUnlinkStatementProviderEvent(Rec, Handled);
    end;

    procedure RefreshStatementProvider(var BankAccount: Record "Bank Account")
    var
        StatementProvider: Text;
    begin
        StatementProvider := SelectBankLinkingService;

        if StatementProvider <> '' then
            OnRefreshStatementProviderEvent(BankAccount, StatementProvider);
    end;

    procedure RenewAccessConsentStatementProvider(var BankAccount: Record "Bank Account")
    var
        StatementProvider: Text;
    begin
        StatementProvider := SelectBankLinkingService;

        if StatementProvider <> '' then
            OnRenewAccessConsentStatementProviderEvent(BankAccount, StatementProvider);
    end;

    procedure UpdateBankAccountLinking()
    var
        StatementProvider: Text;
    begin
        StatementProvider := SelectBankLinkingService;

        if StatementProvider <> '' then
            OnUpdateBankAccountLinkingEvent(Rec, StatementProvider);
    end;

    procedure GetUnlinkedBankAccounts(var TempUnlinkedBankAccount: Record "Bank Account" temporary)
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.FindSet then
            repeat
                if not BankAccount.IsLinkedToBankStatementServiceProvider then begin
                    TempUnlinkedBankAccount := BankAccount;
                    TempUnlinkedBankAccount.Insert;
                end;
            until BankAccount.Next = 0;
    end;

    procedure GetLinkedBankAccounts(var TempUnlinkedBankAccount: Record "Bank Account" temporary)
    var
        BankAccount: Record "Bank Account";
    begin
        if BankAccount.FindSet then
            repeat
                if BankAccount.IsLinkedToBankStatementServiceProvider then begin
                    TempUnlinkedBankAccount := BankAccount;
                    TempUnlinkedBankAccount.Insert;
                end;
            until BankAccount.Next = 0;
    end;

    local procedure SelectBankLinkingService(): Text
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        OptionStr: Text;
        OptionNo: Integer;
    begin
        OnGetStatementProvidersEvent(TempNameValueBuffer);

        if TempNameValueBuffer.IsEmpty then
            exit(''); // Action should not be visible in this case so should not occur

        if (TempNameValueBuffer.Count = 1) or (not GuiAllowed) then
            exit(TempNameValueBuffer.Name);

        TempNameValueBuffer.FindSet;
        repeat
            OptionStr += StrSubstNo('%1,', TempNameValueBuffer.Value);
        until TempNameValueBuffer.Next = 0;
        OptionStr += CancelTxt;

        OptionNo := StrMenu(OptionStr);
        if (OptionNo = 0) or (OptionNo = TempNameValueBuffer.Count + 1) then
            exit;

        TempNameValueBuffer.SetRange(Value, SelectStr(OptionNo, OptionStr));
        TempNameValueBuffer.FindFirst;

        exit(TempNameValueBuffer.Name);
    end;

    procedure IsAutoLogonPossible(): Boolean
    var
        AutoLogonPossible: Boolean;
    begin
        AutoLogonPossible := true;
        OnCheckAutoLogonPossibleEvent(Rec, AutoLogonPossible);
        exit(AutoLogonPossible)
    end;

    local procedure ScheduleBankStatementDownload()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not IsLinkedToBankStatementServiceProvider then
            Error(BankAccNotLinkedErr);
        if not IsAutoLogonPossible then
            Error(AutoLogonNotPossibleErr);

        JobQueueEntry.ScheduleRecurrentJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"Automatic Import of Bank Stmt.", RecordId);
        JobQueueEntry.Description :=
          CopyStr(StrSubstNo(BankStmtScheduledDownloadDescTxt, Name), 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."Notify On Success" := false;
        JobQueueEntry."No. of Minutes between Runs" := 121;
        JobQueueEntry.Modify;
        if Confirm(JobQEntriesCreatedQst) then
            ShowBankStatementDownloadJobQueueEntry;
    end;

    local procedure UnscheduleBankStatementDownload()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetAutomaticImportJobQueueEntryFilters(JobQueueEntry);
        if not JobQueueEntry.IsEmpty then
            JobQueueEntry.DeleteAll;
    end;

    procedure CreateNewAccount(OnlineBankAccLink: Record "Online Bank Acc. Link")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
    begin
        GeneralLedgerSetup.Get;
        Init;
        Validate("Bank Account No.", OnlineBankAccLink."Bank Account No.");
        Validate(Name, OnlineBankAccLink.Name);
        if OnlineBankAccLink."Currency Code" <> '' then
            CurrencyCode := GeneralLedgerSetup.GetCurrencyCode(OnlineBankAccLink."Currency Code");
        Validate("Currency Code", CurrencyCode);
        Validate(Contact, OnlineBankAccLink.Contact);
    end;

    local procedure ShowBankStatementDownloadJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetAutomaticImportJobQueueEntryFilters(JobQueueEntry);
        if JobQueueEntry.FindFirst then
            PAGE.Run(PAGE::"Job Queue Entry Card", JobQueueEntry);
    end;

    local procedure SetAutomaticImportJobQueueEntryFilters(var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"Automatic Import of Bank Stmt.");
        JobQueueEntry.SetRange("Record ID to Process", RecordId);
    end;

    local procedure CheckDeleteBalancingBankAccount()
    var
        PaymentRegistrationSetup: Record "Payment Registration Setup";
    begin
        PaymentRegistrationSetup.SetRange("Bal. Account Type", PaymentRegistrationSetup."Bal. Account Type"::"Bank Account");
        PaymentRegistrationSetup.SetRange("Bal. Account No.", "No.");
        if PaymentRegistrationSetup.IsEmpty then
            exit;

        if not GuiAllowed then
            Error(CannotDeleteBalancingBankAccountErr);

        if not Confirm(ConfirmDeleteBalancingBankAccountQst) then
            Error('');
    end;

    procedure GetOnlineFeedStatementStatus(var OnlineFeedStatus: Option; var Linked: Boolean)
    begin
        Linked := false;
        OnlineFeedStatus := OnlineFeedStatementStatus::"Not Linked";
        if IsLinkedToBankStatementServiceProvider then begin
            Linked := true;
            OnlineFeedStatus := OnlineFeedStatementStatus::Linked;
            if IsScheduledBankStatement then
                OnlineFeedStatus := OnlineFeedStatementStatus::"Linked and Auto. Bank Statement Enabled";
        end;
    end;

    local procedure IsScheduledBankStatement(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Record ID to Process", RecordId);
        exit(JobQueueEntry.FindFirst);
    end;

    procedure DisableStatementProviders()
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
    begin
        OnGetStatementProvidersEvent(TempNameValueBuffer);
        if TempNameValueBuffer.FindSet then
            repeat
                OnDisableStatementProviderEvent(TempNameValueBuffer.Name);
            until TempNameValueBuffer.Next = 0;
    end;

    local procedure IsContactUpdateNeeded(): Boolean
    var
        BankContUpdate: Codeunit "BankCont-Update";
        UpdateNeeded: Boolean;
    begin
        UpdateNeeded :=
          (Name <> xRec.Name) or
          ("Search Name" <> xRec."Search Name") or
          ("Name 2" <> xRec."Name 2") or
          (Address <> xRec.Address) or
          ("Address 2" <> xRec."Address 2") or
          (City <> xRec.City) or
          ("Phone No." <> xRec."Phone No.") or
          ("Telex No." <> xRec."Telex No.") or
          ("Territory Code" <> xRec."Territory Code") or
          ("Currency Code" <> xRec."Currency Code") or
          ("Language Code" <> xRec."Language Code") or
          ("Our Contact Code" <> xRec."Our Contact Code") or
          ("Country/Region Code" <> xRec."Country/Region Code") or
          ("Fax No." <> xRec."Fax No.") or
          ("Telex Answer Back" <> xRec."Telex Answer Back") or
          ("Post Code" <> xRec."Post Code") or
          (County <> xRec.County) or
          ("E-Mail" <> xRec."E-Mail") or
          ("Home Page" <> xRec."Home Page");

        if not UpdateNeeded and not IsTemporary then
            UpdateNeeded := BankContUpdate.ContactNameIsBlank("No.");

        OnAfterIsUpdateNeeded(xRec, Rec, UpdateNeeded);
        exit(UpdateNeeded);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsUpdateNeeded(BankAccount: Record "Bank Account"; xBankAccount: Record "Bank Account"; var UpdateNeeded: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var BankAccount: Record "Bank Account"; var xBankAccount: Record "Bank Account"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeValidateShortcutDimCode(var BankAccount: Record "Bank Account"; var xBankAccount: Record "Bank Account"; FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckLinkedToStatementProviderEvent(var BankAccount: Record "Bank Account"; var IsLinked: Boolean)
    begin
        // The subscriber of this event should answer whether the bank account is linked to a bank statement provider service
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckAutoLogonPossibleEvent(var BankAccount: Record "Bank Account"; var AutoLogonPossible: Boolean)
    begin
        // The subscriber of this event should answer whether the bank account can be logged on to without multi-factor authentication
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUnlinkStatementProviderEvent(var BankAccount: Record "Bank Account"; var Handled: Boolean)
    begin
        // The subscriber of this event should unlink the bank account from a bank statement provider service
    end;

    [IntegrationEvent(false, false)]
    procedure OnMarkAccountLinkedEvent(var OnlineBankAccLink: Record "Online Bank Acc. Link"; var BankAccount: Record "Bank Account")
    begin
        // The subscriber of this event should Mark the account linked to a bank statement provider service
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSimpleLinkStatementProviderEvent(var OnlineBankAccLink: Record "Online Bank Acc. Link"; var StatementProvider: Text)
    begin
        // The subscriber of this event should link the bank account to a bank statement provider service
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLinkStatementProviderEvent(var BankAccount: Record "Bank Account"; var StatementProvider: Text)
    begin
        // The subscriber of this event should link the bank account to a bank statement provider service
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRefreshStatementProviderEvent(var BankAccount: Record "Bank Account"; var StatementProvider: Text)
    begin
        // The subscriber of this event should refresh the bank account linked to a bank statement provider service
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnGetDataExchangeDefinitionEvent(var DataExchDefCodeResponse: Code[20]; var Handled: Boolean)
    begin
        // This event should retrieve the data exchange definition format for processing the online feeds
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateBankAccountLinkingEvent(var BankAccount: Record "Bank Account"; var StatementProvider: Text)
    begin
        // This event should handle updating of the single or multiple bank accounts
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetStatementProvidersEvent(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
        // The subscriber of this event should insert a unique identifier (Name) and friendly name of the provider (Value)
    end;

    [Scope('OnPrem')]
    procedure CheckCashDesks()
    begin
        // NAVCZ
        if "No." <> '' then
            CashDeskMgt.CheckCashDesk("No.");
        CashDeskMgt.CheckCashDesks;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDisableStatementProviderEvent(ProviderName: Text)
    begin
        // The subscriber of this event should disable the statement provider with the given name
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRenewAccessConsentStatementProviderEvent(var BankAccount: Record "Bank Account"; var StatementProvider: Text)
    begin
        // The subscriber of this event should provide the UI for renewing access consent to the linked open banking bank account
    end;


}

