-- liquibase formatted sql
-- changeset SAMQA:1754374146773 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\account_entrp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/account_entrp.sql:null:d4b2dea519b33b17c81dee3515d8c7ef6c0d889f:create

alter table samqa.account
    add constraint account_entrp
        foreign key ( entrp_id )
            references samqa.enterprise ( entrp_id )
        enable;

