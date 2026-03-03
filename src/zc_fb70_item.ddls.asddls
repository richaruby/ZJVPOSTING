@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FB70 Upload - Item (Projection)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_FB70_Item
  as projection on ZI_FB70_Item
{
  key ItemUUID,
      HeaderUUID,
      Kunnr,
      Lifnr,
      SpecialGlIndicator,
      PaymentMethod,
      AssignmentReference,
      ItemText,
      TaxCode,
      BusinessPlace,
      Housebank,
      BankAcc,
      Costcenter,
      GlAccount,
      DrcrInd,
      NetAmount,
      Currency,
      Plant,
      ProfitCenter, 
      Bank_acc,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,

      _Header : redirected to parent ZC_FB70_Header
}
