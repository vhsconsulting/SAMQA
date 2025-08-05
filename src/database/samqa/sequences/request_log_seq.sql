create sequence samqa.request_log_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 467 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"5b8c222d9d845810c9e44584703443f8f3d8c448","type":"SEQUENCE","name":"REQUEST_LOG_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>REQUEST_LOG_SEQ</NAME>\n   <START_WITH>467</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}