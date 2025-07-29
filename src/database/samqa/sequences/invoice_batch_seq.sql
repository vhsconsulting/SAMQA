create sequence samqa.invoice_batch_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 509679 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"0013bc30b5d42f1037de3d14e69fd1571864e9b5","type":"SEQUENCE","name":"INVOICE_BATCH_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_BATCH_SEQ</NAME>\n   <START_WITH>509679</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}