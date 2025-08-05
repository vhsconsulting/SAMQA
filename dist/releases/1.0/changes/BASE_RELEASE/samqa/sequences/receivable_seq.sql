-- liquibase formatted sql
-- changeset SAMQA:1754374149859 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\receivable_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/receivable_seq.sql:null:2644734cdd98546a687332ad75d213b59c6657e7:create

create sequence samqa.receivable_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder nocycle
nokeep noscale global;

