create sequence samqa.demo_images_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 31 cache 20 noorder nocycle
nokeep noscale global;


-- sqlcl_snapshot {"hash":"fcb809d76b06d3aa6019b177ce0e3b4d97ce01ec","type":"SEQUENCE","name":"DEMO_IMAGES_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DEMO_IMAGES_SEQ</NAME>\n   <START_WITH>31</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}