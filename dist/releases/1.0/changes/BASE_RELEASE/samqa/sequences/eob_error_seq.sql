-- liquibase formatted sql
-- changeset SAMQA:1754374148611 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\eob_error_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/eob_error_seq.sql:null:ac272d1bc532de0cf2673302049b9518fcbbe406:create

create sequence samqa.eob_error_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 6539 nocache noorder nocycle
nokeep noscale global;

