create sequence samqa.claim_edi_hdr_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder
nocycle nokeep noscale global;


-- sqlcl_snapshot {"hash":"a035ce5f983b51a0c93591240b94befee3f6b445","type":"SEQUENCE","name":"CLAIM_EDI_HDR_SEQ","schemaName":"SAMQA","sxml":"\n  <SEQUENCE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIM_EDI_HDR_SEQ</NAME>\n   <START_WITH>21</START_WITH>\n   <INCREMENT>1</INCREMENT>\n   <MINVALUE>1</MINVALUE>\n   <MAXVALUE>999999999999999999999999999</MAXVALUE>\n   <CACHE>20</CACHE>\n   <SCALE>NOSCALE</SCALE>\n</SEQUENCE>"}