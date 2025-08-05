-- liquibase formatted sql
-- changeset SAMQA:1754374164959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\bi_xml_chart_templates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/bi_xml_chart_templates.sql:null:cfb44f3a4c97e2b10d75ffd2636eb0d62b07208e:create

create or replace editionable trigger samqa.bi_xml_chart_templates before
    insert on samqa.xml_chart_templates
    for each row
begin
    for c1 in (
        select
            xml_chart_templates_seq.nextval next_val
        from
            dual
    ) loop
        :new.primkey := c1.next_val;
    end loop;
end;
/

alter trigger samqa.bi_xml_chart_templates enable;

