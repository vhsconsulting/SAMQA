-- liquibase formatted sql
-- changeset SAMQA:1754373932814 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payroll_contribution_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payroll_contribution_n1.sql:null:1999862fee089905ae3304ea9bc236981f7281b8:create

create index samqa.payroll_contribution_n1 on
    samqa.payroll_contribution (
        invoice_id
    );

