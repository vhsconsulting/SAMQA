-- liquibase formatted sql
-- changeset SAMQA:1753779762586 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_renewal_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_renewal_seq.sql:null:82cabf3b7495aa4ea68893625cab3c2e390e1f12:create

create sequence samqa.online_renewal_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 28113 cache 20 noorder
nocycle nokeep noscale global;

