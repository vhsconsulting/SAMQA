-- liquibase formatted sql
-- changeset SAMQA:1754374147927 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\claim_interface_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/claim_interface_seq.sql:null:b3d3ad5903d6972de1e947ffc574406b67d651dc:create

create sequence samqa.claim_interface_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 3610769 cache 20 noorder
nocycle nokeep noscale global;

