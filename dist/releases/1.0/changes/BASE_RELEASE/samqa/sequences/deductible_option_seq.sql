-- liquibase formatted sql
-- changeset SAMQA:1754374148237 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\deductible_option_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/deductible_option_seq.sql:null:55ebe17437c544afaf90d37648b692a67e994a6b:create

create sequence samqa.deductible_option_seq minvalue 1001 maxvalue 999999999 increment by 1 start with 335331 nocache noorder nocycle
nokeep noscale global;

