-- liquibase formatted sql
-- changeset SAMQA:1754373937289 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.account_preference_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.account_preference_seq.sql:null:ef967f779110168bc8ed3d3e74995be54a3b8de9:create

grant select on samqa.account_preference_seq to rl_sam_rw;

