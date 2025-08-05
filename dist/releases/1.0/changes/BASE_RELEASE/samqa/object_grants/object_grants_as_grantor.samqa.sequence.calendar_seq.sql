-- liquibase formatted sql
-- changeset SAMQA:1754373937417 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.calendar_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.calendar_seq.sql:null:ec27affdf94394e3250035ed04bf6000e204655c:create

grant select on samqa.calendar_seq to rl_sam_rw;

