-- liquibase formatted sql
-- changeset SAMQA:1754374165017 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\claimn_bir.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/claimn_bir.sql:null:9b6e199907d623c5455aa5d64d2e74f00ff2f2d6:create

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

