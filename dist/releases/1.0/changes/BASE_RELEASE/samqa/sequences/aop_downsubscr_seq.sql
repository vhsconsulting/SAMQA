-- liquibase formatted sql
-- changeset SAMQA:1754374147480 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\aop_downsubscr_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/aop_downsubscr_seq.sql:null:69d75173b3b0a1954277351dab423d11f8f29768:create

create sequence samqa.aop_downsubscr_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20 noorder
nocycle nokeep noscale global;

