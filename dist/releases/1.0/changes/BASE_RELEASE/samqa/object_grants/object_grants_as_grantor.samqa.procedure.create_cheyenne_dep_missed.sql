-- liquibase formatted sql
-- changeset SAMQA:1754373936760 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.create_cheyenne_dep_missed.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.create_cheyenne_dep_missed.sql:null:78eb837a0ed727a966ddc06e71f1c58a998710ed:create

grant execute on samqa.create_cheyenne_dep_missed to rl_sam1_ro;

grant execute on samqa.create_cheyenne_dep_missed to rl_sam_ro;

grant execute on samqa.create_cheyenne_dep_missed to rl_sam_rw;

grant debug on samqa.create_cheyenne_dep_missed to rl_sam1_ro;

grant debug on samqa.create_cheyenne_dep_missed to sgali;

grant debug on samqa.create_cheyenne_dep_missed to rl_sam_rw;

