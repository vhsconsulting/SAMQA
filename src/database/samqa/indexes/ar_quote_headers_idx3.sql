create index samqa.ar_quote_headers_idx3 on
    samqa.ar_quote_headers (
        entrp_id
    );


-- sqlcl_snapshot {"hash":"b316e1d20208eae766a1f59587e7724977c75e42","type":"INDEX","name":"AR_QUOTE_HEADERS_IDX3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_QUOTE_HEADERS_IDX3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_QUOTE_HEADERS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}