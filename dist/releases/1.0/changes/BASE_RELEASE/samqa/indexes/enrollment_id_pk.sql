-- liquibase formatted sql
-- changeset SAMQA:1754373931316 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\enrollment_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/enrollment_id_pk.sql:null:2fbdd980d9196211d1a7d0cb2bed353eb941693f:create

create unique index samqa.enrollment_id_pk on
    samqa.online_fsa_hra_staging (
        enrollment_id
    );

