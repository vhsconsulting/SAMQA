create index samqa.metavante_settlements_n5 on
    samqa.metavante_settlements (
        claim_id
    );


-- sqlcl_snapshot {"hash":"1d61c2b469afcdd983d6f4b438c965ab48971f92","type":"INDEX","name":"METAVANTE_SETTLEMENTS_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_SETTLEMENTS_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_SETTLEMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}