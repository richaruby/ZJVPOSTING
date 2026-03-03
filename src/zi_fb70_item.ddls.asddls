@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FB70 Upload - Item (Interface)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_FB70_Item
  as select from zfb70_itm
  association to parent ZI_FB70_Header as _Header on $projection.HeaderUUID = _Header.HeaderUUID
{
  key item_uuid       as ItemUUID,
      header_uuid     as HeaderUUID,

      gl_account      as GlAccount,
      kunnr                                          as Kunnr,
      lifnr                                          as Lifnr,
      special_gl_indicator                           as SpecialGlIndicator,
      payment_method                                 as PaymentMethod,
      assignment_reference                           as AssignmentReference,
      item_text                                      as ItemText,
      tax_code                                       as TaxCode,
      business_place                                 as BusinessPlace,
      
      bank_acc                                       as BankAcc,
      costcenter                                     as Costcenter,
      drcr_ind        as DrcrInd,

      @Semantics.amount.currencyCode: 'Currency'
      net_amount      as NetAmount,
      currency        as Currency,
      plant           as Plant,
      profit_center   as ProfitCenter,
      housebank       as Housebank,
      bank_acc        as Bank_acc,
      
      created_by      as CreatedBy,
      created_at      as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,

      _Header
}
