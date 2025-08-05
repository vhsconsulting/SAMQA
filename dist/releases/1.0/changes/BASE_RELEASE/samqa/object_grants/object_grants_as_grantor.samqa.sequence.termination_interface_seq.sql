-- liquibase formatted sql
-- changeset SAMQA:1754373938293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.termination_interface_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.termination_interface_seq.sql:null:567ebb934120820c2c274c34d7795de6614e1bb3:create

grant select on samqa.termination_interface_seq to rl_sam_rw;

