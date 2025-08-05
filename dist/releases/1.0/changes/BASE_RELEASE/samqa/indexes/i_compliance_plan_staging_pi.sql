-- liquibase formatted sql
-- changeset SAMQA:1754373931570 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\i_compliance_plan_staging_pi.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/i_compliance_plan_staging_pi.sql:null:86953cbefb8f6d86e51224780a84b8b9728e6915:create

create index samqa.i_compliance_plan_staging_pi on
    samqa.compliance_plan_staging (
        batch_number,
        entity_id,
        plan_id,
        plan_type
    );

