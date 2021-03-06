codeunit 5491 "Graph Mgt - Shipment Method"
{

    trigger OnRun()
    begin
    end;

    [Obsolete('Integration Records will be replaced by SystemID and SystemLastDateTimeModified', '17.0')]
    procedure UpdateIntegrationRecords(OnlyItemsWithoutId: Boolean)
    var
        ShipmentMethod: Record "Shipment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        ShipmentMethodRecordRef: RecordRef;
    begin
        ShipmentMethodRecordRef.Open(DATABASE::"Shipment Method");
        GraphMgtGeneralTools.UpdateIntegrationRecords(ShipmentMethodRecordRef, ShipmentMethod.FieldNo(Id), OnlyItemsWithoutId);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    local procedure HandleApiSetup()
    begin
        UpdateIntegrationRecords(false);
    end;
}

