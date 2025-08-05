-- liquibase formatted sql
-- changeset SAMQA:1754373942593 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.listfile_typ.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.listfile_typ.sql:null:1e9733c96d62838028e53e0d5fa08fd173af0214:create

grant execute on samqa.listfile_typ to rl_sam1_ro;

grant execute on samqa.listfile_typ to rl_sam_rw;

grant execute on samqa.listfile_typ to rl_sam_ro;

