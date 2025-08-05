-- liquibase formatted sql
-- changeset SAMQA:1754374148325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\department_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/department_seq.sql:null:0b5fcdfbf5a3d0a6b632e369ed3bc6eae92dd291:create

create sequence samqa.department_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 161 cache 20 noorder nocycle
nokeep noscale global;

