create sequence samqa.invoice_upload_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 3827 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"307359df76d28415e8d85cfe7de30ff2a89703ea","type":"SEQUENCE","name":"INVOICE_UPLOAD_ID_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_UPLOAD_ID_SEQ</NAME>\n   <START_WITH>3827</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>9999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}