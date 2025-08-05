-- liquibase formatted sql
-- changeset SAMQA:1754373944983 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.pop_renewal_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.pop_renewal_v.sql:null:f1e0435856897ad19e06c97b8b79d8e14d12c2df:create

grant select on samqa.pop_renewal_v to rl_sam1_ro;

grant select on samqa.pop_renewal_v to rl_sam_rw;

grant select on samqa.pop_renewal_v to rl_sam_ro;

