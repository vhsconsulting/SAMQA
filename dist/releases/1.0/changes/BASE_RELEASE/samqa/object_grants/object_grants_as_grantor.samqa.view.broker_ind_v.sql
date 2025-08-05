-- liquibase formatted sql
-- changeset SAMQA:1754373943095 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_ind_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_ind_v.sql:null:c4df9caab9bb8c679155ae76f73abc0fca60b116:create

grant select on samqa.broker_ind_v to rl_sam1_ro;

grant select on samqa.broker_ind_v to rl_sam_rw;

grant select on samqa.broker_ind_v to rl_sam_ro;

grant select on samqa.broker_ind_v to sgali;

