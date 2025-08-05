-- liquibase formatted sql
-- changeset SAMQA:1754374147840 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\checkbook_gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/checkbook_gp_seq.sql:null:35de49fff3f6242864a1fdf1cd2398094963a554:create

create sequence samqa.checkbook_gp_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 81 cache 20 noorder
nocycle nokeep noscale global;

