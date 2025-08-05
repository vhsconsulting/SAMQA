-- liquibase formatted sql
-- changeset SAMQA:1754373938117 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.payment_acc_info_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.payment_acc_info_seq.sql:null:fa9142c18dd4463f017e745c80fccb49def6ff4e:create

grant select on samqa.payment_acc_info_seq to rl_sam_rw;

