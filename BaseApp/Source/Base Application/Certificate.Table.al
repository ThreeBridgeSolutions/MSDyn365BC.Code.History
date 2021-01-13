table 11014 Certificate
{
    Caption = 'Certificate';
    ObsoleteReason = 'Moved to Elster extension, new table Elster-Certificate.';
    ObsoleteState = Pending;
    ObsoleteTag = '15.0';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(2; "Certificate Type"; Option)
        {
            Caption = 'Certificate Type';
            InitValue = "Soft token";
            OptionCaption = 'Soft token,Hardware token';
            OptionMembers = "Soft token","Hardware token";

            trigger OnValidate()
            begin
                if "Certificate Type" <> "Certificate Type"::"Soft token" then
                    Error(Text1140000, "Certificate Type");
            end;
        }
        field(4; "PFX File"; BLOB)
        {
            Caption = 'PFX File';
        }
        field(5; "Elster Certificate"; BLOB)
        {
            Caption = 'Elster Certificate';
        }
        field(6; "PFX File Password"; BLOB)
        {
            Caption = 'PFX File Password';
        }
        field(7; "Client Certificate"; BLOB)
        {
            Caption = 'Client Certificate';
        }
        field(8; "Client Certificate Password"; BLOB)
        {
            Caption = 'Client Certificate Password';
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnRename()
    begin
        if "User ID" <> xRec."User ID" then
            Error(RenameNotAllowedErr, FieldCaption("User ID"));
    end;

    var
        Text1140000: Label 'Only Certificates of type %1 are supported until now.';
        CryptographyManagement: Codeunit "Cryptography Management";
        EncryptionMustBeEnabledErr: Label 'You must enable encryption before you can perform this action.';
        RenameNotAllowedErr: Label 'Modification of %1 is not allowed.', Comment = '%1=Field name';

    [Scope('OnPrem')]
    procedure SavePassword(PasswordText: Text; FieldNo: Integer)
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        EncriptPassword(TempBlob, PasswordText);
        WriteBlobToField(TempBlob, FieldNo);
    end;

    [Scope('OnPrem')]
    procedure GetPassword(FieldNo: Integer): Text
    var
        TempBlob: Codeunit "Temp Blob";
        CryptographyManagement: Codeunit "Cryptography Management";
        InStream: InStream;
        PasswordText: Text;
    begin
        if not CryptographyManagement.IsEncryptionPossible then
            Error(EncryptionMustBeEnabledErr);

        TempBlob.FromRecord(Rec, FieldNo);
        TempBlob.CreateInStream(InStream);
        InStream.Read(PasswordText);
        exit(CryptographyManagement.Decrypt(PasswordText));
    end;

    [Scope('OnPrem')]
    procedure WriteBlobToField(TempBlob: Codeunit "Temp Blob"; FieldNo: Integer)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo);
        RecordRef.Modify;
    end;

    local procedure EncriptPassword(var TempBlob: Codeunit "Temp Blob"; PasswordText: Text)
    var
        OutStream: OutStream;
    begin
        if not CryptographyManagement.IsEncryptionPossible then
            Error(EncryptionMustBeEnabledErr);
        PasswordText := CryptographyManagement.Encrypt(PasswordText);
        TempBlob.CreateOutStream(OutStream);
        OutStream.Write(PasswordText);
    end;
}
