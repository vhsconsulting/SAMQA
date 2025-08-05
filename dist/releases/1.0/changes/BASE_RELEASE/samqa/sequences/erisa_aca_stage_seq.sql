-- liquibase formatted sql
-- changeset SAMQA:1754374148674 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\erisa_aca_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/erisa_aca_stage_seq.sql:null:5a5dfcd80e6097c0c27165fae7d0580162d2bc8c:create

create sequence samqa.erisa_aca_stage_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 362 cache 20 noorder
nocycle nokeep noscale global;

