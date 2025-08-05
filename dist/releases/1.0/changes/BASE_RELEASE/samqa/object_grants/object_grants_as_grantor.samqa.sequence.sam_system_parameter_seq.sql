-- liquibase formatted sql
-- changeset SAMQA:1754373938230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sam_system_parameter_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sam_system_parameter_seq.sql:null:ad7017fd897b11ecce30929afba630bed4ffdd27:create

grant select on samqa.sam_system_parameter_seq to rl_sam_rw;

