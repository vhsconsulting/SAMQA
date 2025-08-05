-- liquibase formatted sql
-- changeset SAMQA:1754374149549 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\opp_attachment_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/opp_attachment_id_seq.sql:null:07fa348110c22efbc19385256bc150e037ad5a42:create

create sequence samqa.opp_attachment_id_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1297 cache 20 noorder
nocycle nokeep noscale global;

