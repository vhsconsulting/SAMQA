-- liquibase formatted sql
-- changeset SAMQA:1754374149848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\receivable_details_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/receivable_details_seq.sql:null:1101dbdef8eb3639d7c79877fb4a80ae43f1d5e4:create

create sequence samqa.receivable_details_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder
nocycle nokeep noscale global;

