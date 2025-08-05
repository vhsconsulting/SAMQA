-- liquibase formatted sql
-- changeset SAMQA:1754373944071 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_erisa_5500_renewal_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_erisa_5500_renewal_v.sql:null:513ff8f2c6af96813e2737d040392bd231790c9a:create

grant select on samqa.fsa_hra_erisa_5500_renewal_v to rl_sam1_ro;

grant select on samqa.fsa_hra_erisa_5500_renewal_v to rl_sam_ro;

grant select on samqa.fsa_hra_erisa_5500_renewal_v to rl_sam_rw;

