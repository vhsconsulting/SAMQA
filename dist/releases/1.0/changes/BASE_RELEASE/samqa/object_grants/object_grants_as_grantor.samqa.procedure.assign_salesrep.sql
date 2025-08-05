-- liquibase formatted sql
-- changeset SAMQA:1754373936674 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.assign_salesrep.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.assign_salesrep.sql:null:f0189c8464c3123268e93111eea840444a21b6c5:create

grant execute on samqa.assign_salesrep to rl_sam_ro;

grant execute on samqa.assign_salesrep to rl_sam_rw;

grant execute on samqa.assign_salesrep to rl_sam1_ro;

grant debug on samqa.assign_salesrep to sgali;

grant debug on samqa.assign_salesrep to rl_sam_rw;

grant debug on samqa.assign_salesrep to rl_sam1_ro;

