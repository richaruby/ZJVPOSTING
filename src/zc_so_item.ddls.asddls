@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'So Item so Delivery'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_SO_ITEM as projection on ZI_SO_Item
{
    key ItemUUID,
    HeaderUUID,
    SalesOrderItem,
    PurchaseOrderByCustomer,
    PurchaseOrderByShipToParty,
    Material,
    MaterialByCustomer,
    RequestedQuantity,
    Batch,
    ProductionPlant,
    StorageLocation,
    DeliveryPriority,
    IncotermsClassification,
    IncotermsTransferLocation,
    IncotermsLocation1,
    CustomerPaymentTerms,
    ConditionType1,
    ConditionRateValue1,
    ConditionType2,
    ConditionRateValue2,
    ConditionType3,
    ConditionRateValue3,
    PartnerFunction1,
    Customer1,
    PartnerFunction2,
    Customer2,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    /* Associations */
    _Header : redirected to parent ZC_SO_Header
}
