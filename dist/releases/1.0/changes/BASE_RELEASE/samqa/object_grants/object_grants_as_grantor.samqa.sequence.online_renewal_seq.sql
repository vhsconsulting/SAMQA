-- liquibase formatted sql
-- changeset SAMQA:1754373938084 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.online_renewal_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.online_renewal_seq.sql:null:3dfdd1d74589bac130855d558eaac7159fd864b7:create

grant select on samqa.online_renewal_seq to rl_sam_rw;

