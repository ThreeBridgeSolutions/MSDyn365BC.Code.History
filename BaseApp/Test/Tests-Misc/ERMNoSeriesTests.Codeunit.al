codeunit 134370 "ERM No. Series Tests"
{
    Subtype = Test;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        StartingNumberTxt: Label 'ABC00010D';
        SecondNumberTxt: Label 'ABC00020D';
        EndingNumberTxt: Label 'ABC00090D';
        StartingNumber2Txt: Label 'X00000000000000001A';

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestStartingNoNoGaps()
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        Initialize;
        CreateNewNumberSeries('TEST', 1, FALSE, NoSeriesLine);
        Assert.AreEqual('', NoSeriesLine.GetLastNoUsed, 'lastUsedNo function before taking a number');

        // test
        Assert.AreEqual(StartingNumberTxt, NoSeriesManagement.GetNextNo(NoSeriesLine."Series Code", TODAY, TRUE), 'No gaps diff');
        Assert.AreEqual(INCSTR(StartingNumberTxt), NoSeriesManagement.GetNextNo(NoSeriesLine."Series Code", TODAY, TRUE), 'No gaps diff');
        NoSeriesLine.FIND;
        Assert.AreEqual(INCSTR(StartingNumberTxt), NoSeriesLine."Last No. Used", 'last no. used field');
        Assert.AreEqual(INCSTR(StartingNumberTxt), NoSeriesLine.GetLastNoUsed, 'lastUsedNo function');

        // clean up
        DeleteNumberSeries('TEST');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestStartingNoWithGaps()
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        Initialize;
        CreateNewNumberSeries('TEST', 1, TRUE, NoSeriesLine);
        Assert.AreEqual('', NoSeriesLine.GetLastNoUsed, 'lastUsedNo function before taking a number');
        Assert.AreEqual(ToBigInt(10), NoSeriesLine."Starting Sequence No.", 'Starting Sequence No. is wrong');
        Assert.AreEqual(ToBigInt(10), NumberSequence.Current(NoSeriesLine."Sequence Name"), 'Current value wrong');

        // test
        Assert.AreEqual(StartingNumberTxt, NoSeriesManagement.GetNextNo(NoSeriesLine."Series Code", TODAY, TRUE), 'With gaps diff');
        Assert.AreEqual(ToBigInt(10), NumberSequence.Current(NoSeriesLine."Sequence Name"), 'Current value wrong');
        Assert.AreEqual(INCSTR(StartingNumberTxt), NoSeriesManagement.GetNextNo(NoSeriesLine."Series Code", TODAY, TRUE), 'With gaps diff');
        Assert.AreEqual(ToBigInt(11), NumberSequence.Current(NoSeriesLine."Sequence Name"), 'Current value wrong');
        NoSeriesLine.FIND;
        Assert.AreEqual('', NoSeriesLine."Last No. Used", 'last no. used field');
        Assert.AreEqual(INCSTR(StartingNumberTxt), NoSeriesLine.GetLastNoUsed, 'lastUsedNo function');

        // clean up
        DeleteNumberSeries('TEST');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestChangingToAllowGaps()
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        Initialize;
        CreateNewNumberSeries('TEST', 10, FALSE, NoSeriesLine);
        Assert.AreEqual('', NoSeriesLine.GetLastNoUsed, 'lastUsedNo function before taking a number');
        Assert.AreEqual(ToBigInt(0), NoSeriesLine."Starting Sequence No.", 'Starting Sequence No. is wrong');

        // test - enable Allow gaps
        Assert.AreEqual(StartingNumberTxt, NoSeriesManagement.GetNextNo(NoSeriesLine."Series Code", TODAY, TRUE), 'With gaps diff');
        NoSeriesLine.FIND;
        NoSeriesLine.VALIDATE("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        Assert.AreEqual(ToBigInt(0), NoSeriesLine."Starting Sequence No.", 'Starting Sequence No. is wrong after conversion');
        Assert.AreEqual('', NoSeriesLine."Last No. Used", 'last no. used field');
        Assert.AreEqual(StartingNumberTxt, NoSeriesLine.GetLastNoUsed, 'lastUsedNo function after conversion');
        Assert.AreEqual(SecondNumberTxt, NoSeriesManagement.GetNextNo(NoSeriesLine."Series Code", TODAY, TRUE), 'GetNextNo after conversion');
        Assert.AreEqual(SecondNumberTxt, NoSeriesLine.GetLastNoUsed, 'lastUsedNo after taking new no. after conversion');
        // Change back to not allow gaps
        NoSeriesLine.FIND;
        NoSeriesLine.VALIDATE("Allow Gaps in Nos.", false);
        NoSeriesLine.Modify();
        Assert.AreEqual(SecondNumberTxt, NoSeriesLine."Last No. Used", 'last no. used field after reset');
        Assert.AreEqual(SecondNumberTxt, NoSeriesLine.GetLastNoUsed, 'lastUsedNo  after reset');

        // clean up
        DeleteNumberSeries('TEST');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestChangingToAllowGapsDateOrder()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        Initialize;
        CreateNewNumberSeries('TEST', 10, FALSE, NoSeriesLine);
        NoSeries.Get('TEST');
        NoSeries."Date Order" := true;
        NoSeries.Modify();

        // test - enable Allow gaps should not be allowed
        AssertError NoSeriesLine.VALIDATE("Allow Gaps in Nos.", true);

        // clean up
        DeleteNumberSeries('TEST');
    end;

    local procedure CreateNewNumberSeries(NewName: Code[20]; IncrementBy: Integer; AllowGaps: Boolean; var NoSeriesLine: Record "No. Series Line")
    var
        NoSeries: Record "No. Series";
    begin
        NoSeries.Code := NewName;
        NoSeries.Description := NewName;
        NoSeries.INSERT;

        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.VALIDATE("Starting No.", StartingNumberTxt);
        NoSeriesLine.VALIDATE("Ending No.", EndingNumberTxt);
        NoSeriesLine."Increment-by No." := IncrementBy;
        NoSeriesLine.INSERT(TRUE);
        NoSeriesLine.VALIDATE("Allow Gaps in Nos.", AllowGaps);
        NoSeriesLine.Modify(TRUE);
    end;

    local procedure DeleteNumberSeries(NameToDelete: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        IF NoSeriesLine.GET(NameToDelete, 10000) THEN
            NoSeriesLine.DELETE(TRUE);
        IF NoSeries.GET(NameToDelete) THEN
            NoSeries.DELETE(TRUE);
    end;

    local procedure ToBigInt(IntValue: Integer): BigInteger
    begin
        EXIT(IntValue);
    end;

    local procedure Initialize()
    begin
        LibraryLowerPermissions.SetO365BusFull;
    end;
}
