-- liquibase formatted sql
-- changeset SAMQA:1754373929430 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ben_plan_approvals_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ben_plan_approvals_n3.sql:null:dc90480437e251db6508a43c4acbc399d2af0979:create

create index samqa.ben_plan_approvals_n3 on
    samqa.ben_plan_approvals (
        batch_number
    );

