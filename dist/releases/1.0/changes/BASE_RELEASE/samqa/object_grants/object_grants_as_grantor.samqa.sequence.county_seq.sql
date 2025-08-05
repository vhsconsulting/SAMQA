-- liquibase formatted sql
-- changeset SAMQA:1754373937552 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.county_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.county_seq.sql:null:35066d2b6bef3f6d5df48dc4ccba37efeddb0192:create

grant select on samqa.county_seq to rl_sam_rw;

