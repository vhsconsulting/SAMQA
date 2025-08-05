create sequence samqa.demo_order_items_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"b7daf54460ba81b7d5671cc3abf7890cf3076466","type":"SEQUENCE","name":"DEMO_ORDER_ITEMS_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEMO_ORDER_ITEMS_SEQ</NAME>\n   <START_WITH>41</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}