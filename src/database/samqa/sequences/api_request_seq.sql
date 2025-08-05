create sequence samqa.api_request_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 2345 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"54f896805c39c54928ed7528d469398ca413262e","type":"SEQUENCE","name":"API_REQUEST_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>API_REQUEST_SEQ</NAME>\n   <START_WITH>2345</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}