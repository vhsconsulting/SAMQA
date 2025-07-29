create sequence samqa.checkbook_gp_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 81 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"35de49fff3f6242864a1fdf1cd2398094963a554","type":"SEQUENCE","name":"CHECKBOOK_GP_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CHECKBOOK_GP_SEQ</NAME>\n   <START_WITH>81</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}