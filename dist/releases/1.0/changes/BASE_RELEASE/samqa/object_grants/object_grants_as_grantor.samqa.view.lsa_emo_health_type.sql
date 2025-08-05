-- liquibase formatted sql
-- changeset SAMQA:1754373944506 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.lsa_emo_health_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.lsa_emo_health_type.sql:null:c8481068d30a5f0dd0bcc3f71be0528f1ed14d94:create

grant select on samqa.lsa_emo_health_type to rl_sam1_ro;

grant select on samqa.lsa_emo_health_type to rl_sam_ro;

grant select on samqa.lsa_emo_health_type to rl_sam_rw;

