-- liquibase formatted sql
-- changeset SAMQA:1754373944310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hrafsa_claim_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hrafsa_claim_detail_v.sql:null:b6582aedc558429f3feb707f060e694a457ff75a:create

grant select on samqa.hrafsa_claim_detail_v to rl_sam1_ro;

grant select on samqa.hrafsa_claim_detail_v to rl_sam_rw;

grant select on samqa.hrafsa_claim_detail_v to rl_sam_ro;

grant select on samqa.hrafsa_claim_detail_v to sgali;

