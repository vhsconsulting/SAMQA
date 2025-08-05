create index samqa.ar_quote_lines_idx on
    samqa.ar_quote_lines (
        quote_header_id
    );


-- sqlcl_snapshot {"hash":"4a76b5c7d10eead90a4bbb793c6371607f6ceb3d","type":"INDEX","name":"AR_QUOTE_LINES_IDX","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_QUOTE_LINES_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_QUOTE_LINES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>QUOTE_HEADER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}