create sequence samqa.invoice_number_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 817090 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"394e0c2e07efc8841e3c610770b7d24fd9819bd4","type":"SEQUENCE","name":"INVOICE_NUMBER_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_NUMBER_SEQ</NAME>\n   <START_WITH>817090</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}