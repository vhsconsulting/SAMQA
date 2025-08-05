-- liquibase formatted sql
-- changeset SAMQA:1754374146784 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\account_pers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/account_pers.sql:null:934f4d6c61a2ddac096d78b4e0b9b6b7429f513b:create

alter table samqa.account
    add constraint account_pers
        foreign key ( pers_id )
            references samqa.person ( pers_id )
        enable;

