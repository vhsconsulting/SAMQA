create index samqa.enterprise_f1 on
    samqa.enterprise ( replace(entrp_code, '-') );


-- sqlcl_snapshot {"hash":"a56aa659d18c587a1461e2411452b228f9283911","type":"INDEX","name":"ENTERPRISE_F1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENTERPRISE_F1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENTERPRISE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>REPLACE(\"ENTRP_CODE\",'-')</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}