create index samqa.claimn_n12 on
    samqa.claimn (
        unsubstantiated_flag
    );


-- sqlcl_snapshot {"hash":"b0182a044da9a067f024b96c89ee1e462eb31b72","type":"INDEX","name":"CLAIMN_N12","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIMN_N12</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIMN</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>UNSUBSTANTIATED_FLAG</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}