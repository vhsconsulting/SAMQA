-- liquibase formatted sql
-- changeset SAMQA:1754373939567 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.crm_employer_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.crm_employer_mv.sql:null:2ba072b1e2c778b71db7d96d9c5908d4d10fc1be:create

grant delete on samqa.crm_employer_mv to rl_sam_rw;

grant insert on samqa.crm_employer_mv to rl_sam_rw;

grant select on samqa.crm_employer_mv to rl_sam1_ro;

grant select on samqa.crm_employer_mv to rl_sam_ro;

grant select on samqa.crm_employer_mv to rl_sam_rw;

grant update on samqa.crm_employer_mv to rl_sam_rw;

