create index samqa.account_n9_ga_id on
    samqa.account (
        ga_id
    );


-- sqlcl_snapshot {"hash":"dcda8f477ea2f9436447c6b794cf8592491504f0","type":"INDEX","name":"ACCOUNT_N9_GA_ID","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACCOUNT_N9_GA_ID</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACCOUNT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>GA_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}