-- liquibase formatted sql
-- changeset SAMQA:1754373932409 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enrollment_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enrollment_n1.sql:null:7921db2499118baf1619e67f771c8643422070d4:create

create index samqa.online_enrollment_n1 on
    samqa.online_enrollment (
        acc_num,
        pers_id
    );

