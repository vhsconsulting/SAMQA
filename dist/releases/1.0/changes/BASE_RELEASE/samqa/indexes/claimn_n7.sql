-- liquibase formatted sql
-- changeset SAMQA:1754373930479 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\claimn_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/claimn_n7.sql:null:4192fcfd1b822a2226659e5dfa85908baf42e613:create

create index samqa.claimn_n7 on
    samqa.claimn (
        service_type,
        plan_start_date,
        plan_end_date
    );

