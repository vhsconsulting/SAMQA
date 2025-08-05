-- liquibase formatted sql
-- changeset SAMQA:1754374149118 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\irs_amendment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/irs_amendment_seq.sql:null:136c872f094258e110d791d5b515f4a68b60ab16:create

create sequence samqa.irs_amendment_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 81 cache 20 noorder
nocycle nokeep noscale global;

