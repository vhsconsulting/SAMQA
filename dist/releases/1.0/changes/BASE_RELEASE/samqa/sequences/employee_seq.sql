-- liquibase formatted sql
-- changeset SAMQA:1754374148450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\employee_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/employee_seq.sql:null:a6aec23f2c3704c6fbd2e3ac78a4bb68ef32533c:create

create sequence samqa.employee_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 7833 cache 20 noorder nocycle
nokeep noscale global;

