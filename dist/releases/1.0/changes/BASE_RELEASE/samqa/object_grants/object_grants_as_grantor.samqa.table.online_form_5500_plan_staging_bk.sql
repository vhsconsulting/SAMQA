-- liquibase formatted sql
-- changeset SAMQA:1754373941422 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_form_5500_plan_staging_bk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_form_5500_plan_staging_bk.sql:null:23681d5e92931e805c80af565415884bb295db6b:create

grant select on samqa.online_form_5500_plan_staging_bk to rl_sam_ro;

