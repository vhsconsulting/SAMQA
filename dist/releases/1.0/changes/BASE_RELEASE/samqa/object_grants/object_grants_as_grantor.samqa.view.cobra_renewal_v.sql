-- liquibase formatted sql
-- changeset SAMQA:1754373943414 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_renewal_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_renewal_v.sql:null:b56291e84ad3050e71fca468488c6618bdc52b18:create

grant select on samqa.cobra_renewal_v to rl_sam1_ro;

grant select on samqa.cobra_renewal_v to rl_sam_rw;

grant select on samqa.cobra_renewal_v to rl_sam_ro;

