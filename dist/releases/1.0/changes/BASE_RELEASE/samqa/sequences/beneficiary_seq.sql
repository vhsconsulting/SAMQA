-- liquibase formatted sql
-- changeset SAMQA:1754374147652 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\beneficiary_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/beneficiary_seq.sql:null:650ef3944a6ad7a8c945f559cfc92daeafaf5292:create

create sequence samqa.beneficiary_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 254022 cache 20 noorder
nocycle nokeep noscale global;

