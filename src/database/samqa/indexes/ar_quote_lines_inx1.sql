create index samqa.ar_quote_lines_inx1 on
    samqa.ar_quote_lines (
        quote_line_id
    );


-- sqlcl_snapshot {"hash":"e372b1f43cd242b8daf34d98f632674c68a1929b","type":"INDEX","name":"AR_QUOTE_LINES_INX1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_QUOTE_LINES_INX1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_QUOTE_LINES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>QUOTE_LINE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}