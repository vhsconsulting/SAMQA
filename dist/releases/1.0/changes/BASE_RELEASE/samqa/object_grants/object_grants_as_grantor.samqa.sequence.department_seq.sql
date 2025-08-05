-- liquibase formatted sql
-- changeset SAMQA:1754373937632 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.department_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.department_seq.sql:null:7228f5b72ec18ae34254bdb5e5f4a53a2d65376c:create

grant select on samqa.department_seq to rl_sam_rw;

