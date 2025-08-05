-- liquibase formatted sql
-- changeset SAMQA:1754373931593 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\i_online_compliance_staging_pi.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/i_online_compliance_staging_pi.sql:null:a26c7469907ae0b1ee68ce47bc4edc8b2ecd9d6f:create

create index samqa.i_online_compliance_staging_pi on
    samqa.online_compliance_staging (
        batch_number,
        entrp_id
    );

