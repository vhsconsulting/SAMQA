create sequence samqa.item_master_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 101 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"2ba196c629dd0263d2ddaed6002a35f9b3f6a912","type":"SEQUENCE","name":"ITEM_MASTER_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ITEM_MASTER_SEQ</NAME>\n   <START_WITH>101</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}