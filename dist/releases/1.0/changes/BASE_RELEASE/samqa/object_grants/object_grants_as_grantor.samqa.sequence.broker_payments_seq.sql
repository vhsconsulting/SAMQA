-- liquibase formatted sql
-- changeset SAMQA:1754373937409 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.broker_payments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.broker_payments_seq.sql:null:9bed802e8dfe750741c7d74e419555cfa900a406:create

grant select on samqa.broker_payments_seq to rl_sam_rw;

