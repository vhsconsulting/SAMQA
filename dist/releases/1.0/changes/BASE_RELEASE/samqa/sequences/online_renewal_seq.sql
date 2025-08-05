-- liquibase formatted sql
-- changeset SAMQA:1754374149507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_renewal_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_renewal_seq.sql:null:fd9ec66c73c9048b78ab6760556459f349917ca0:create

create sequence samqa.online_renewal_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 28153 cache 20 noorder
nocycle nokeep noscale global;

