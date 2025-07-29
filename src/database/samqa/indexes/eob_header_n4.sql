create index samqa.eob_header_n4 on
    samqa.eob_header (
        claim_number
    );


-- sqlcl_snapshot {"hash":"ede8c132b67c0db43b56729340f21e759e248fe2","type":"INDEX","name":"EOB_HEADER_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EOB_HEADER_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EOB_HEADER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}