-- liquibase formatted sql
-- changeset SAMQA:1754374147043 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\income_contributor.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/income_contributor.sql:null:696c594e08950255cbb6452d23a116fa1dac5035:create

alter table samqa.income
    add constraint income_contributor
        foreign key ( contributor )
            references samqa.enterprise ( entrp_id )
        enable;

