-- liquibase formatted sql
-- changeset SAMQA:1754374148178 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\daily_enroll_renewl_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/daily_enroll_renewl_seq.sql:null:92541556c5a47f5b338306d90bd762ffdbcfdcd7:create

create sequence samqa.daily_enroll_renewl_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1402 cache 20
noorder nocycle nokeep noscale global;

