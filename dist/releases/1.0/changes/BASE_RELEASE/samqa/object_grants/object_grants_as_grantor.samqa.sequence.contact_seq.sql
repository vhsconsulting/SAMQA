-- liquibase formatted sql
-- changeset SAMQA:1754373937541 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.contact_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.contact_seq.sql:null:3837d89f483bbdc98e45a379f22309573a904deb:create

grant select on samqa.contact_seq to rl_sam_rw;

