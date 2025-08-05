-- liquibase formatted sql
-- changeset SAMQA:1754374147877 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\claim_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/claim_detail_seq.sql:null:00c51efce92692f758ac38545f47d03807e24766:create

create sequence samqa.claim_detail_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2410604 cache 20 noorder
nocycle nokeep noscale global;

