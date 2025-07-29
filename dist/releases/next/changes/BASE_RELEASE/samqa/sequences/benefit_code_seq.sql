-- liquibase formatted sql
-- changeset SAMQA:1753779760751 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\benefit_code_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/benefit_code_seq.sql:null:588c31a900901f93f22ebe9d70f95419da2c7c4e:create

create sequence samqa.benefit_code_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 360277 cache 20 noorder
nocycle nokeep noscale global;

