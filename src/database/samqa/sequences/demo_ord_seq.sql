create sequence samqa.demo_ord_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 31 cache 20 noorder nocycle
nokeep noscale global;


-- sqlcl_snapshot {"hash":"5001e00430ed6ef59d774937d93e961c297d0b22","type":"SEQUENCE","name":"DEMO_ORD_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEMO_ORD_SEQ</NAME>\n   <START_WITH>31</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}