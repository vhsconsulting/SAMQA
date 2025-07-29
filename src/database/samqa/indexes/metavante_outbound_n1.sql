create index samqa.metavante_outbound_n1 on
    samqa.metavante_outbound (
        action,
        processed_flag
    );


-- sqlcl_snapshot {"hash":"417e34054cef9a0aa4bf5f229bbd280ea4aa743c","type":"INDEX","name":"METAVANTE_OUTBOUND_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>METAVANTE_OUTBOUND_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>METAVANTE_OUTBOUND</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACTION</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PROCESSED_FLAG</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}