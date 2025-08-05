-- liquibase formatted sql
-- changeset SAMQA:1754373929415 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_approvals_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_approvals_n1.sql:null:792ddcdde75ad9acd2cb09c6213d183fd80049a4:create

create index samqa.ben_plan_approvals_n1 on
    samqa.ben_plan_approvals (
        ben_plan_id
    );

