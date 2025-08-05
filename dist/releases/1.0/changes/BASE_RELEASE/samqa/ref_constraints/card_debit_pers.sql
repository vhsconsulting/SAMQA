-- liquibase formatted sql
-- changeset SAMQA:1754374146873 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\card_debit_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/card_debit_pers.sql:null:56b785b70e8a0e88449969ff544029ab65c62cdd:create

alter table samqa.card_debit
    add constraint card_debit_pers
        foreign key ( card_id )
            references samqa.person ( pers_id )
        enable;

