-- liquibase formatted sql
-- changeset SAMQA:1754374150299 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\vendor_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/vendor_seq.sql:null:e1a17cd4f2e06896dd886e551e038d7914e9b6eb:create

create sequence samqa.vendor_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 619766 cache 20 noorder nocycle
nokeep noscale global;

