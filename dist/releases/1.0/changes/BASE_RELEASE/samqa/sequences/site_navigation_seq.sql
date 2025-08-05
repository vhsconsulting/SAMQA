-- liquibase formatted sql
-- changeset SAMQA:1754374150145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\site_navigation_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/site_navigation_seq.sql:null:32a8007a0d6a02cd1f9445320a9f90976f85c89a:create

create sequence samqa.site_navigation_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 995 cache 20 noorder
nocycle nokeep noscale global;

