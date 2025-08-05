-- liquibase formatted sql
-- changeset SAMQA:1754373936132 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_eob.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_eob.sql:null:a6b78842bb00effb3eade9b84187aac40095675d:create

grant execute on samqa.pc_eob to rl_sam_ro;

grant execute on samqa.pc_eob to rl_sam_rw;

grant execute on samqa.pc_eob to rl_sam1_ro;

grant debug on samqa.pc_eob to sgali;

grant debug on samqa.pc_eob to rl_sam_rw;

grant debug on samqa.pc_eob to rl_sam1_ro;

grant debug on samqa.pc_eob to rl_sam_ro;

