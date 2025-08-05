-- liquibase formatted sql
-- changeset SAMQA:1754373938093 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.online_users_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.online_users_seq.sql:null:6b82b219ea017b001f6d71c046b183c280ba263c:create

grant select on samqa.online_users_seq to rl_sam_rw;

