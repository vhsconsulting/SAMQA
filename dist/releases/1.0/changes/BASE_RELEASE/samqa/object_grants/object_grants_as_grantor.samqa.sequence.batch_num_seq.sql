-- liquibase formatted sql
-- changeset SAMQA:1754373937361 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.batch_num_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.batch_num_seq.sql:null:05faca8d3c079904fd4b0022eba998bc218454ff:create

grant select on samqa.batch_num_seq to rl_sam_rw;

