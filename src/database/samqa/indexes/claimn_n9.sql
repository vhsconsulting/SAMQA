create index samqa.claimn_n9 on
    samqa.claimn (
        claim_id,
        claim_status
    );


-- sqlcl_snapshot {"hash":"76365ea6c2f75d99a855879fd686435bd163f30b","type":"INDEX","name":"CLAIMN_N9","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CLAIMN_N9</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CLAIMN</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>CLAIM_STATUS</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}