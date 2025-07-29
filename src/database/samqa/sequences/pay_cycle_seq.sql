create sequence samqa.pay_cycle_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 17007 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"e5ebc524f555347d4136bf299897a0415525f9ff","type":"SEQUENCE","name":"PAY_CYCLE_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAY_CYCLE_SEQ</NAME>\n   <START_WITH>17007</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}