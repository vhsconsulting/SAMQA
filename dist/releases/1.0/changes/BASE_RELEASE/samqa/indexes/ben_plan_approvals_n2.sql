-- liquibase formatted sql
-- changeset SAMQA:1754373929423 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_approvals_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_approvals_n2.sql:null:947dd0d4217842c655ac4ab4a6f2462242bfb565:create

create index samqa.ben_plan_approvals_n2 on
    samqa.ben_plan_approvals (
        entrp_id
    );

