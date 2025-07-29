create sequence samqa.online_renewals_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"9bb482232713b6d9cd7327d5bb3c30cdaee3ecf7","type":"SEQUENCE","name":"ONLINE_RENEWALS_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_RENEWALS_SEQ</NAME>\n   <START_WITH>1</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}