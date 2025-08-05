-- liquibase formatted sql
-- changeset SAMQA:1754374149871 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\relative_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/relative_seq.sql:null:7b19bda69a6579c2ceac41d2b09a7c706065dc97:create

create sequence samqa.relative_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 45 cache 20 noorder nocycle
nokeep noscale global;

