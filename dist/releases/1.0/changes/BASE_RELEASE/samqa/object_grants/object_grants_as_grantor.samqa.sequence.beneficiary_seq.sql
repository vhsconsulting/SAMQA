-- liquibase formatted sql
-- changeset SAMQA:1754373937381 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.beneficiary_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.beneficiary_seq.sql:null:a202ec5120095601c763a813d74c959f0bdc9679:create

grant select on samqa.beneficiary_seq to rl_sam_rw;

