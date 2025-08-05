-- liquibase formatted sql
-- changeset SAMQA:1754374147098 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\investment_acc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/investment_acc.sql:null:6715511de5d875614674aa37c754cdfb7e9de702:create

alter table samqa.investment
    add constraint investment_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;

