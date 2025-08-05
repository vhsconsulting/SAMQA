-- liquibase formatted sql
-- changeset SAMQA:1754373938293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.system_parameters_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.system_parameters_seq.sql:null:3206fe9d677a2c3f7f90062bf208e51ee39993c3:create

grant select on samqa.system_parameters_seq to rl_sam_rw;

