create index samqa.enterprise_f3 on
    samqa.enterprise ( upper(name) );


-- sqlcl_snapshot {"hash":"faff49741bf205bb82fecbb586b6ba7ad349f60e","type":"INDEX","name":"ENTERPRISE_F3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ENTERPRISE_F3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ENTERPRISE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>UPPER(\"NAME\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}