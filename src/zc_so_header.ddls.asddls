@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View For Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_SO_Header
 as projection on ZI_SO_Header
{
  key HeaderUUID,
  SalesOrderType,
  SalesOrganization,
  DistributionChannel,
  OrganizationDivision,
  SalesDistrict,
  SoldToParty,
  PurchaseOrderByCustomer,
  CustomerPurchaseOrderDate,
  TransactionCurrency,
  CustomerPaymentTerms,
  SDDocumentReason,
  RequestedDeliveryDate,
  HeaderBillingBlockReason,
  DeliveryBlockReason,
  AccountingExchangeRate,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  /* Associations */
  _Items as Items : redirected to composition child ZC_SO_ITEM 
}
