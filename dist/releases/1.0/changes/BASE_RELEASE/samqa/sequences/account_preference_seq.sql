-- liquibase formatted sql
-- changeset SAMQA:1753779760466 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\account_preference_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/account_preference_seq.sql:null:d9e51913ab37a3e08ce84828fd550016edffc19a:create

create sequence samqa.account_preference_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 175960 cache 20
noorder nocycle nokeep noscale global;

