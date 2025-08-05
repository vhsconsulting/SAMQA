-- liquibase formatted sql
-- changeset SAMQA:1754373940655 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_interest_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_interest_result_external.sql:null:53c91599a5a1ca2014b8ec61157c457f1d64ad4d:create

grant select on samqa.gp_interest_result_external to rl_sam1_ro;

grant select on samqa.gp_interest_result_external to rl_sam_ro;

