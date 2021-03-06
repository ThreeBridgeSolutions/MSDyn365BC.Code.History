table 5719 "Nonstock Item Setup"
{
    Caption = 'Nonstock Item Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "No. Format"; Enum "Nonstock Item No. Format")
        {
            Caption = 'No. Format';
        }
        field(3; "No. Format Separator"; Code[1])
        {
            Caption = 'No. Format Separator';
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
}

