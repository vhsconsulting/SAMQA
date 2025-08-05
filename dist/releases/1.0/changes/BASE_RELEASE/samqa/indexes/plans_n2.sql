-- liquibase formatted sql
-- changeset SAMQA:1754373933000 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\plans_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/plans_n2.sql:null:e2e8bc3f203e0461a8bc3e99372594ff73cfedce:create

create index samqa.plans_n2 on
    samqa.plans (
        plan_sign
    );

