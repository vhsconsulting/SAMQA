create index samqa.ar_quote_lines_idx4 on
    samqa.ar_quote_lines (
        rate_plan_detail_id
    );


-- sqlcl_snapshot {"hash":"443eb976caec42d035ef629097965cee2958f987","type":"INDEX","name":"AR_QUOTE_LINES_IDX4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_QUOTE_LINES_IDX4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_QUOTE_LINES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>RATE_PLAN_DETAIL_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}