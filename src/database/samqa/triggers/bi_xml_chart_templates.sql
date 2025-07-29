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


-- sqlcl_snapshot {"hash":"1b606daeb5f2f70f9c82fd1aa49c581b8ab340b3","type":"TRIGGER","name":"BI_XML_CHART_TEMPLATES","schemaName":"SAMQA","sxml":""}