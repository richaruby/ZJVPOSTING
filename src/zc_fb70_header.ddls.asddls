@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FB70 Upload - Header (Projection)'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_FB70_Header
  as projection on ZI_FB70_Header
{
  key HeaderUUID,
      CompanyCode,
      TransactionType,
      InvoiceDate,
      PostingDate,
      Reference,
      GrossAmount,
      Currency,
      TaxCalcInd,
      TaxCode,
      BusinessPlace,
      SectionCode,
      Text,
      GstPartner,
      PlaceOfSupply,
      Kunnr,
      Lifnr,
      BaselineDate,
      PaymentTerm,
      Assignment,
      HeaderText,
      WithholdingTaxInd,
      Belnr,
      Gjahr,
      Reversedoc,
      Reverseyr,
      Reverse,
      Reversereason,
      Status,
      Message,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      Doctype,

      _Items as to_Items  : redirected to composition child ZC_FB70_Item
}
