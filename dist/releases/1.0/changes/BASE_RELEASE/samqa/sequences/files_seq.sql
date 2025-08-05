-- liquibase formatted sql
-- changeset SAMQA:1754374148838 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\files_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/files_seq.sql:null:f5392b7b2f4a44b9e61757888dd1ca9a1bbf9bff:create

create sequence samqa.files_seq minvalue 1 maxvalue 9999999999 increment by 1 start with 263 nocache noorder nocycle nokeep noscale global
;

