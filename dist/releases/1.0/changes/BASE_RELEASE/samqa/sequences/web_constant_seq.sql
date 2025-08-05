-- liquibase formatted sql
-- changeset SAMQA:1754374150311 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\web_constant_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/web_constant_seq.sql:null:280d165eba75c0f4f41e0a422806f6a00f4691de:create

create sequence samqa.web_constant_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 61 cache 20 noorder
nocycle nokeep noscale global;

