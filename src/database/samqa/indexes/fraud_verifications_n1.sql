create index samqa.fraud_verifications_n1 on
    samqa.fraud_verifications (
        acc_id
    );


-- sqlcl_snapshot {"hash":"07d30e30cd712c2e27c9c8fa557996f798e99637","type":"INDEX","name":"FRAUD_VERIFICATIONS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>FRAUD_VERIFICATIONS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>FRAUD_VERIFICATIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}