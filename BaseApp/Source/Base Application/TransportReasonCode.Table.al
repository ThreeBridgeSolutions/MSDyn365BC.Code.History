table 12154 "Transport Reason Code"
{
    Caption = 'Transport Reason Code';
    LookupPageID = "Transport Reason Codes";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(5; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(10; "Posted Shpt. Nos."; Code[20])
        {
            Caption = 'Posted Shpt. Nos.';
            TableRelation = "No. Series";
        }
        field(11; "Posted Rcpt. Nos."; Code[20])
        {
            Caption = 'Posted Rcpt. Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Reason Code")
        {
        }
    }
}

