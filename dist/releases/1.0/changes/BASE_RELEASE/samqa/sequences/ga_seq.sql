-- liquibase formatted sql
-- changeset SAMQA:1754374148911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ga_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ga_seq.sql:null:fe9f35e84d3668861893946b63f552b48832d776:create

create sequence samqa.ga_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1121 cache 20 noorder nocycle nokeep
noscale global;

