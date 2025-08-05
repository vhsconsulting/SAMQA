-- liquibase formatted sql
-- changeset SAMQA:1754374147389 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ach_transfer_details_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ach_transfer_details_seq.sql:null:088cb095f590870478c1dc657b6afb71185fd6cc:create

create sequence samqa.ach_transfer_details_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 5142863 cache
20 noorder nocycle nokeep noscale global;

