-- liquibase formatted sql
-- changeset SAMQA:1754373940650 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_interest_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_interest_error_external.sql:null:2c9c37826547ea703a4c66af12ae9e67b930f7c2:create

grant select on samqa.gp_interest_error_external to rl_sam1_ro;

grant select on samqa.gp_interest_error_external to rl_sam_ro;

