-- liquibase formatted sql
-- changeset SAMQA:1753779761252 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\daily_enroll_renewl_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/daily_enroll_renewl_seq.sql:null:b2ab6256f707baafd201acb1796871cd1d0edbde:create

create sequence samqa.daily_enroll_renewl_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1362 cache 20
noorder nocycle nokeep noscale global;

