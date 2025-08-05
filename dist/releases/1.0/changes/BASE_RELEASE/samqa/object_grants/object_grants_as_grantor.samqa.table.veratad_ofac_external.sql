-- liquibase formatted sql
-- changeset SAMQA:1754373942496 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.veratad_ofac_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.veratad_ofac_external.sql:null:e4f7f8f05e564bb151a3ff29fec7b6aae2bc4f75:create

grant select on samqa.veratad_ofac_external to rl_sam1_ro;

grant select on samqa.veratad_ofac_external to rl_sam_ro;

