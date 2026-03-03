@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Upload - Item (Interface)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_SO_Item as select from zso_itm
  association to parent ZI_SO_Header as _Header
    on $projection.HeaderUUID = _Header.HeaderUUID
{
  key item_uuid                    as ItemUUID,
      header_uuid                  as HeaderUUID,

      sales_order_item             as SalesOrderItem,
      purchase_order_by_customer   as PurchaseOrderByCustomer,
      purch_ord_shipto_party          as PurchaseOrderByShipToParty,
      material                     as Material,
      material_by_customer         as MaterialByCustomer,
      requested_quantity           as RequestedQuantity,
      batch                        as Batch,
      production_plant             as ProductionPlant,
      storage_location             as StorageLocation,
      delivery_priority            as DeliveryPriority,
      incoterms_classification     as IncotermsClassification,
      incoterms_transfer_location  as IncotermsTransferLocation,
      incoterms_location1          as IncotermsLocation1,
      customer_payment_terms       as CustomerPaymentTerms,
      condition_type_1             as ConditionType1,
      condition_rate_value_1       as ConditionRateValue1,
      condition_type_2             as ConditionType2,
      condition_rate_value_2       as ConditionRateValue2,
      condition_type_3             as ConditionType3,
      condition_rate_value_3       as ConditionRateValue3,
      partner_function_1           as PartnerFunction1,
      customer_1                   as Customer1,
      partner_function_2           as PartnerFunction2,
      customer_2                   as Customer2,

      created_by                   as CreatedBy,
      created_at                   as CreatedAt,
      last_changed_by              as LastChangedBy,
      last_changed_at              as LastChangedAt,

      _Header  
}
