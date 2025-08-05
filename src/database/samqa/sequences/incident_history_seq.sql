create sequence samqa.incident_history_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 67510 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"c5bf64f2c5d008b2afa691901d8740fe92dd1aec","type":"SEQUENCE","name":"INCIDENT_HISTORY_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INCIDENT_HISTORY_SEQ</NAME>\n   <START_WITH>67510</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}