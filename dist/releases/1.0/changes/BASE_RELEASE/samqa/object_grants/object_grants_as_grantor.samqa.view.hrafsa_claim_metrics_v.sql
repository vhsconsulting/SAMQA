-- liquibase formatted sql
-- changeset SAMQA:1754373944317 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hrafsa_claim_metrics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hrafsa_claim_metrics_v.sql:null:73603d9f49f3f262daf72224c44aa7e114bc4aee:create

grant select on samqa.hrafsa_claim_metrics_v to rl_sam1_ro;

grant select on samqa.hrafsa_claim_metrics_v to rl_sam_rw;

grant select on samqa.hrafsa_claim_metrics_v to rl_sam_ro;

grant select on samqa.hrafsa_claim_metrics_v to sgali;

