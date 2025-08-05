create sequence samqa.invoice_batch_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 509739 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"bd22236c0fd747c664076fd1c6bcdf7f31a9f74e","type":"SEQUENCE","name":"INVOICE_BATCH_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_BATCH_SEQ</NAME>\n   <START_WITH>509739</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}