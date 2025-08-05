-- liquibase formatted sql
-- changeset SAMQA:1754373938103 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.pay_details_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.pay_details_seq.sql:null:dd0bb4a99158ef2ffc4c5e94fda2d1ae847e99e2:create

grant select on samqa.pay_details_seq to rl_sam_rw;

