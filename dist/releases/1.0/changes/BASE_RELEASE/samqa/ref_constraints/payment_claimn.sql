-- liquibase formatted sql
-- changeset SAMQA:1754374147166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\payment_claimn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/payment_claimn.sql:null:1ae08f5fd31f43386e5b563ae045e5ddd207dd25:create

alter table samqa.payment
    add constraint payment_claimn
        foreign key ( claimn_id )
            references samqa.claimn ( claim_id )
        disable;

