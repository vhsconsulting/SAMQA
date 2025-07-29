create index samqa.account_n4 on
    samqa.account (
        closed_reason
    );


-- sqlcl_snapshot {"hash":"a67a155dcdd470775f778d2aa219868aa8dfc448","type":"INDEX","name":"ACCOUNT_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACCOUNT_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACCOUNT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLOSED_REASON</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}