-- liquibase formatted sql
-- changeset SAMQA:1753779762800 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\plan_notice_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/plan_notice_seq.sql:null:35a0da2ac5ee9e66899d763351eed749b754b26f:create

create sequence samqa.plan_notice_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 202219 cache 20 noorder
nocycle nokeep noscale global;

