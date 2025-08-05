-- liquibase formatted sql
-- changeset SAMQA:1754373932822 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payroll_contribution_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payroll_contribution_n2.sql:null:062703de905bf0b4943698da593c72bb91ea0c88:create

create index samqa.payroll_contribution_n2 on
    samqa.payroll_contribution (
        entrp_id
    );

