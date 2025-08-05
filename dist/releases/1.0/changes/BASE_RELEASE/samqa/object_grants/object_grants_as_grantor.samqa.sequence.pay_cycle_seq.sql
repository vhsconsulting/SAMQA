-- liquibase formatted sql
-- changeset SAMQA:1754373938099 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.pay_cycle_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.pay_cycle_seq.sql:null:37fbaf0fab7fddd88f957c51cd69278d5535d8dc:create

grant select on samqa.pay_cycle_seq to rl_sam_rw;

