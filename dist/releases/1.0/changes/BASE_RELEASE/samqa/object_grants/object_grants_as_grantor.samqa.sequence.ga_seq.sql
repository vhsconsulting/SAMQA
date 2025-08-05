-- liquibase formatted sql
-- changeset SAMQA:1754373937833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ga_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ga_seq.sql:null:c29231f93996aaf89ddb2b99b44e30740e20f6a2:create

grant select on samqa.ga_seq to rl_sam_rw;

