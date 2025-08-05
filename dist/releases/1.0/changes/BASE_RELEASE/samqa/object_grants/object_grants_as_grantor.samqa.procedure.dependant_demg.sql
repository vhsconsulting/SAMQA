-- liquibase formatted sql
-- changeset SAMQA:1754373936841 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.dependant_demg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.dependant_demg.sql:null:260db3c7de10aac6b5364fc238637606455399cd:create

grant execute on samqa.dependant_demg to rl_sam_ro;

grant execute on samqa.dependant_demg to rl_sam_rw;

grant execute on samqa.dependant_demg to rl_sam1_ro;

grant debug on samqa.dependant_demg to sgali;

grant debug on samqa.dependant_demg to rl_sam_rw;

grant debug on samqa.dependant_demg to rl_sam1_ro;

