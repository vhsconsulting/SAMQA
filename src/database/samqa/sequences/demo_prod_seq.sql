create sequence samqa.demo_prod_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder nocycle
nokeep noscale global;


-- sqlcl_snapshot {"hash":"d21d57ede366eb83ca80cc7c4619de30b242213f","type":"SEQUENCE","name":"DEMO_PROD_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEMO_PROD_SEQ</NAME>\n   <START_WITH>41</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}