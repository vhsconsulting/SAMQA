-- liquibase formatted sql
-- changeset SAMQA:1754373931236 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_detail_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_detail_id_pk.sql:null:07980b43e9061dce0204ffb0cc6e372164a910ae:create

create unique index samqa.enrollment_detail_id_pk on
    samqa.online_fsa_hra_plan_staging (
        enrollment_detail_id
    );

