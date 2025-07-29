create index samqa.ar_quote_headers_idx4 on
    samqa.ar_quote_headers (
        batch_number
    );


-- sqlcl_snapshot {"hash":"6eb759dd6c3b39765917d3488073dab289d2b11a","type":"INDEX","name":"AR_QUOTE_HEADERS_IDX4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_QUOTE_HEADERS_IDX4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_QUOTE_HEADERS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}