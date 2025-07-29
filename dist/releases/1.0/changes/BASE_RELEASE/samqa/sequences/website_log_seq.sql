-- liquibase formatted sql
-- changeset SAMQA:1753779763404 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\website_log_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/website_log_seq.sql:null:a033543e111ac5def174ce58bf82f0230d3f3806:create

create sequence samqa.website_log_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1587151177 cache 20 noorder
nocycle nokeep noscale global;

