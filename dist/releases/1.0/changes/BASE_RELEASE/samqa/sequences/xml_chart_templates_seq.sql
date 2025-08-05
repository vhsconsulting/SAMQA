-- liquibase formatted sql
-- changeset SAMQA:1754374150363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\xml_chart_templates_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/xml_chart_templates_seq.sql:null:983bb879ffbf71f50eb8a7508bc8c1e9d10321a3:create

create sequence samqa.xml_chart_templates_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 141 cache 20 noorder
nocycle nokeep noscale global;

