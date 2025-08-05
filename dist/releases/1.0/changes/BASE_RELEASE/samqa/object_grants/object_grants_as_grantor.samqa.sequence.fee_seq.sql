-- liquibase formatted sql
-- changeset SAMQA:1754373937789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.fee_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.fee_seq.sql:null:47789bb802c53b2a2c2cd37cad713ac16240a543:create

grant select on samqa.fee_seq to rl_sam_rw;

