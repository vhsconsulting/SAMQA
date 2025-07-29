create index samqa.ar_quote_lines_idx3 on
    samqa.ar_quote_lines (
        rate_plan_id
    );


-- sqlcl_snapshot {"hash":"2437eae90f714e05d2e05f7012caa63f9ab4cc36","type":"INDEX","name":"AR_QUOTE_LINES_IDX3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_QUOTE_LINES_IDX3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_QUOTE_LINES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>RATE_PLAN_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}