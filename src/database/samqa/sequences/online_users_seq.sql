create sequence samqa.online_users_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 624038 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"29e54a1b93276c340590ba1d27dc9143cdc921b2","type":"SEQUENCE","name":"ONLINE_USERS_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_USERS_SEQ</NAME>\n   <START_WITH>624038</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}