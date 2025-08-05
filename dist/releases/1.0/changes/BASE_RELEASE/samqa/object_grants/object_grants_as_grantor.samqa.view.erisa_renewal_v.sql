-- liquibase formatted sql
-- changeset SAMQA:1754373943863 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.erisa_renewal_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.erisa_renewal_v.sql:null:2a23079696632054cc42d08003470b68d04df4b0:create

grant select on samqa.erisa_renewal_v to rl_sam1_ro;

grant select on samqa.erisa_renewal_v to rl_sam_rw;

grant select on samqa.erisa_renewal_v to rl_sam_ro;

