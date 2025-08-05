-- liquibase formatted sql
-- changeset SAMQA:1754373942587 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.listfile_tbl_typ.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.listfile_tbl_typ.sql:null:af415e97b55d122fa38150efc86408564f3954ee:create

grant execute on samqa.listfile_tbl_typ to rl_sam1_ro;

grant execute on samqa.listfile_tbl_typ to rl_sam_rw;

grant execute on samqa.listfile_tbl_typ to rl_sam_ro;

