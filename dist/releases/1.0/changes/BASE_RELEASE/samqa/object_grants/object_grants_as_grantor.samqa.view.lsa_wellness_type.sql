-- liquibase formatted sql
-- changeset SAMQA:1754373944522 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.lsa_wellness_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.lsa_wellness_type.sql:null:d2aaf19407ffbfb0c444dab5f85407ad2147d9b7:create

grant select on samqa.lsa_wellness_type to rl_sam1_ro;

grant select on samqa.lsa_wellness_type to rl_sam_ro;

grant select on samqa.lsa_wellness_type to rl_sam_rw;

