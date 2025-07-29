create sequence samqa.payment_acc_info_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"092d140e9767f78240ffb6d9e07f76e6553d8377","type":"SEQUENCE","name":"PAYMENT_ACC_INFO_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>PAYMENT_ACC_INFO_SEQ</NAME>\n   <START_WITH>41</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}