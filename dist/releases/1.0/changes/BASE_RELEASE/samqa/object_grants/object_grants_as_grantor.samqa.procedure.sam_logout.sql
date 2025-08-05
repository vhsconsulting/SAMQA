-- liquibase formatted sql
-- changeset SAMQA:1754373937162 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.sam_logout.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.sam_logout.sql:null:5ecfe30be2005b257facdf5c4fa62ff6ecbe8d64:create

grant execute on samqa.sam_logout to rl_sam_ro;

grant execute on samqa.sam_logout to rl_sam_rw;

grant execute on samqa.sam_logout to rl_sam1_ro;

grant debug on samqa.sam_logout to sgali;

grant debug on samqa.sam_logout to rl_sam_rw;

grant debug on samqa.sam_logout to rl_sam1_ro;

