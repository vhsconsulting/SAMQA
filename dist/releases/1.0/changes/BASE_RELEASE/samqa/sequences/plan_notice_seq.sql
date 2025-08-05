-- liquibase formatted sql
-- changeset SAMQA:1754374149722 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\plan_notice_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/plan_notice_seq.sql:null:b28ebfac5ea7d01f5f87e1cfad1771c3dbed48e3:create

create sequence samqa.plan_notice_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 202559 cache 20 noorder
nocycle nokeep noscale global;

