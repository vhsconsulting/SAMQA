-- liquibase formatted sql
-- changeset SAMQA:1754373944077 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_erisa_renewal_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_erisa_renewal_v.sql:null:ae450fa42c0f7aae52c95ce9369617afe145572a:create

grant select on samqa.fsa_hra_erisa_renewal_v to rl_sam1_ro;

grant select on samqa.fsa_hra_erisa_renewal_v to rl_sam_rw;

grant select on samqa.fsa_hra_erisa_renewal_v to rl_sam_ro;

