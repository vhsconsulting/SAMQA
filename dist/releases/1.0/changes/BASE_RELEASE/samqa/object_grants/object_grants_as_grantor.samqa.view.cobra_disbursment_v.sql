-- liquibase formatted sql
-- changeset SAMQA:1754373943379 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_disbursment_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_disbursment_v.sql:null:ec3a38e95d12d60b98f45749486ab3ef3a0fbc65:create

grant select on samqa.cobra_disbursment_v to rl_sam1_ro;

grant select on samqa.cobra_disbursment_v to rl_sam_rw;

grant select on samqa.cobra_disbursment_v to rl_sam_ro;

