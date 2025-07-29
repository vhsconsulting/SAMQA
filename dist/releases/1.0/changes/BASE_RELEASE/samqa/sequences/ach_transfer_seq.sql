-- liquibase formatted sql
-- changeset SAMQA:1753779760490 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ach_transfer_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ach_transfer_seq.sql:null:39959e40f70eb09055a3bd9e8ab1d3506f6e935c:create

create sequence samqa.ach_transfer_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2261884 cache 20 noorder
nocycle nokeep noscale global;

