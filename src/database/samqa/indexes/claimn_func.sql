create index samqa.claimn_func on
    samqa.claimn ( trunc(approved_date) );


-- sqlcl_snapshot {"hash":"5b81f16649681e55ac8b4229735ab5449fdfbfc1","type":"INDEX","name":"CLAIMN_FUNC","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIMN_FUNC</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIMN</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRUNC(\"APPROVED_DATE\")</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}