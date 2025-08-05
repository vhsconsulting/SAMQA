-- liquibase formatted sql
-- changeset SAMQA:1754373937489 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.cobra_disbursement_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.cobra_disbursement_detail_seq.sql:null:31353adcdde5032aea35e6fc1028cbb3fb1a7495:create

grant select on samqa.cobra_disbursement_detail_seq to rl_sam_rw;

