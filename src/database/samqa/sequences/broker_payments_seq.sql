create sequence samqa.broker_payments_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 23062 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"d0dd0262220d9ed0cd04bbb4a342b80456638a2c","type":"SEQUENCE","name":"BROKER_PAYMENTS_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_PAYMENTS_SEQ</NAME>\n   <START_WITH>23062</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}