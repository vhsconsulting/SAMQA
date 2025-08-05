-- liquibase formatted sql
-- changeset SAMQA:1754374148500 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\en_type_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/en_type_seq.sql:null:be63730dbf3b32a9c78a31c950c20bea71ea2f5e:create

create sequence samqa.en_type_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 48 cache 20 noorder nocycle
nokeep noscale global;

