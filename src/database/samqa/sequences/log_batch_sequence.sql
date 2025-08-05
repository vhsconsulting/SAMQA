create sequence samqa.log_batch_sequence minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 37377 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"55f299cbbaaaf4b7bd4a49a3dc7624ac4502fb0d","type":"SEQUENCE","name":"LOG_BATCH_SEQUENCE","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>LOG_BATCH_SEQUENCE</NAME>\n   <START_WITH>37377</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}