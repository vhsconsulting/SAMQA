-- liquibase formatted sql
-- changeset SAMQA:1754373932426 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\online_enrollment_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/online_enrollment_n3.sql:null:94cabee1b5b6f2424ed997f7916fff9e3144dc3d:create

create index samqa.online_enrollment_n3 on
    samqa.online_enrollment (
        batch_number,
        entrp_id
    );

