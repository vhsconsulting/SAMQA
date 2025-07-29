create or replace editionable trigger samqa.claimn_bir before
    insert or update on samqa.claimn
    for each row
begin
  /* :NEW.CLAIM_PAID := NVL(PC_CLAIM.sum_claimn_payment(:NEW.CLAIM_ID),0);
   :NEW.CLAIM_PENDING := :NEW.CLAIM_AMOUNT-NVL( :NEW.CLAIM_PAID,0);   */
    null;
    if :new.claim_date is null then
        :new.claim_date := sysdate;
    end if;

end;
/

alter trigger samqa.claimn_bir enable;


-- sqlcl_snapshot {"hash":"df3f836ba134c189b2db5559a84b944345b1c659","type":"TRIGGER","name":"CLAIMN_BIR","schemaName":"SAMQA","sxml":""}