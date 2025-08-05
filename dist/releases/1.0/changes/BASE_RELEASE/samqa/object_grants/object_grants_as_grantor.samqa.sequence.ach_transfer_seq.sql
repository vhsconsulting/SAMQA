-- liquibase formatted sql
-- changeset SAMQA:1754373937298 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ach_transfer_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ach_transfer_seq.sql:null:b220a05cee1df51f0baddc54d1d502da6e507c4e:create

grant select on samqa.ach_transfer_seq to rl_sam_rw;

