create sequence samqa.security_questions_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 61 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"86da1897fc88a8d7b00271cf79b6c5dea80bd4ed","type":"SEQUENCE","name":"SECURITY_QUESTIONS_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SECURITY_QUESTIONS_SEQ</NAME>\n   <START_WITH>61</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}