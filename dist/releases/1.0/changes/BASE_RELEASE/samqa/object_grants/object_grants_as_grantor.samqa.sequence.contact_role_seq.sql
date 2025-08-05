-- liquibase formatted sql
-- changeset SAMQA:1754373937536 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.contact_role_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.contact_role_seq.sql:null:6515de8533aed0a10711eb7b6ad9a0c1d78f5d5a:create

grant select on samqa.contact_role_seq to rl_sam_rw;

