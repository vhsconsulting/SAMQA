-- liquibase formatted sql
-- changeset SAMQA:1754374146862 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\card_debit_emitent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/card_debit_emitent.sql:null:385f75a339a89c8ccca52d5707bffbe306b59a0d:create

alter table samqa.card_debit
    add constraint card_debit_emitent
        foreign key ( emitent )
            references samqa.enterprise ( entrp_id )
        enable;

