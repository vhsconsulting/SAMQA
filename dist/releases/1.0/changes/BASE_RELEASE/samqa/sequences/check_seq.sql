-- liquibase formatted sql
-- changeset SAMQA:1754374147828 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\check_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/check_seq.sql:null:63dfb5221c646285c3ed241cf8ca06a6b27ef56e:create

create sequence samqa.check_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder nocycle
nokeep noscale global;

