-- liquibase formatted sql
-- changeset SAMQA:1753779760764 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\benefit_codes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/benefit_codes_seq.sql:null:5ede9939d673b831e3929bd28499745cb914cf2f:create

create sequence samqa.benefit_codes_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 149792 cache 20 noorder
nocycle nokeep noscale global;

