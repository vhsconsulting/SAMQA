-- liquibase formatted sql
-- changeset SAMQA:1754373938089 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.online_renewals_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.online_renewals_seq.sql:null:a7283bf1f0bb35a64a7a009514f1ef784b401636:create

grant select on samqa.online_renewals_seq to rl_sam_rw;

