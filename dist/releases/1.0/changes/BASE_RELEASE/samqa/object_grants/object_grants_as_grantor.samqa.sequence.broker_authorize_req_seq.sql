-- liquibase formatted sql
-- changeset SAMQA:1754373937405 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.broker_authorize_req_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.broker_authorize_req_seq.sql:null:0176d29d464bf114e16e54090311582e59b597f5:create

grant select on samqa.broker_authorize_req_seq to rl_sam_rw;

