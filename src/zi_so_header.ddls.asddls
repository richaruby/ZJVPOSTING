@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Upload - Header (Interface)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SO_Header
as select from zso_hdr
  composition [0..*] of ZI_SO_Item as _Items
{
  key header_uuid                 as HeaderUUID,

      sales_order_type            as SalesOrderType,
      sales_organization          as SalesOrganization,
      distribution_channel        as DistributionChannel,
      organization_division       as OrganizationDivision,
      sales_district              as SalesDistrict,
      sold_to_party               as SoldToParty,
      purchase_order_by_customer  as PurchaseOrderByCustomer,
      customer_purchase_order_date as CustomerPurchaseOrderDate,
      transaction_currency        as TransactionCurrency,
      customer_payment_terms      as CustomerPaymentTerms,
      sd_document_reason          as SDDocumentReason,
      requested_delivery_date     as RequestedDeliveryDate,
      header_billing_block_reason as HeaderBillingBlockReason,
      delivery_block_reason       as DeliveryBlockReason,
      accounting_exchange_rate    as AccountingExchangeRate,

      created_by                  as CreatedBy,
      created_at                  as CreatedAt,
      last_changed_by             as LastChangedBy,
      last_changed_at             as LastChangedAt,
      _Items
}
