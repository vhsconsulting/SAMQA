-- liquibase formatted sql
-- changeset SAMQA:1754374147088 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\invest_transfer_investment_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/invest_transfer_investment_fk.sql:null:316e043cf7034d4897e7ba6ac99273d55eebe3fb:create

alter table samqa.invest_transfer
    add constraint invest_transfer_investment_fk
        foreign key ( investment_id )
            references samqa.investment ( investment_id )
        enable;

