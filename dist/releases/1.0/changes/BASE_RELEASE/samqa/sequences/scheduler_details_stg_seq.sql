-- liquibase formatted sql
-- changeset SAMQA:1754374150069 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\scheduler_details_stg_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/scheduler_details_stg_seq.sql:null:0ae6efa80bf554a2874d4095ec3b85141a0d2d5c:create

create sequence samqa.scheduler_details_stg_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2623367 cache
20 noorder nocycle nokeep noscale global;

