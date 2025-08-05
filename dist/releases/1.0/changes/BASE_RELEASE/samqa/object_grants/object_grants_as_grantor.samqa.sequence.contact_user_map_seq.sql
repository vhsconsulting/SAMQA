-- liquibase formatted sql
-- changeset SAMQA:1754373937547 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.contact_user_map_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.contact_user_map_seq.sql:null:4aa2bd44f704f14c2b353dc08f55dc4dfc3524e2:create

grant select on samqa.contact_user_map_seq to rl_sam_rw;

