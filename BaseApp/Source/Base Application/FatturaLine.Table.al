table 12204 "Fattura Line"
{
    Caption = 'Fattura Line';

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(2; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'Document,Order,Shipment,Payment,Extended Text,VAT';
            OptionMembers = Document,"Order",Shipment,Payment,"Extended Text",VAT;
        }
        field(3; "Related Line No."; Integer)
        {
            Caption = 'Related Line No.';
        }
        field(5; Type; Text[20])
        {
            Caption = 'Type';
        }
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(11; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(13; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(14; "Unit of Measure"; Text[50])
        {
            Caption = 'Unit of Measure';
        }
        field(15; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(20; "Discount Percent"; Decimal)
        {
            Caption = 'Discount Percent';
        }
        field(21; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
        }
        field(30; "VAT %"; Decimal)
        {
            Caption = 'VAT %';
        }
        field(31; "VAT Transaction Nature"; Code[4])
        {
            Caption = 'VAT Transaction Nature';
            TableRelation = "VAT Transaction Nature";
        }
        field(32; "VAT Base"; Decimal)
        {
            Caption = 'VAT Base';
        }
        field(33; "VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
        }
        field(34; "VAT Nature Description"; Text[100])
        {
            Caption = 'VAT Nature Description';
        }
        field(35; "Ext. Text Source No"; Text[30])
        {
            Caption = 'Ext. Text Source No';
        }
        field(40; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(41; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(42; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
    }

    keys
    {
        key(Key1; "Line No.", "Line Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

