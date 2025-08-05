-- liquibase formatted sql
-- changeset SAMQA:1754374148895 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ga_lic_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ga_lic_seq.sql:null:4b80d2b5b65787f055b3cd63b7893b261058ab1b:create

create sequence samqa.ga_lic_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1981 cache 20 noorder nocycle
nokeep noscale global;

