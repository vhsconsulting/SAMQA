create index samqa.ach_transfer_details_n2 on
    samqa.ach_transfer_details (
        transaction_id,
        acc_id
    );


-- sqlcl_snapshot {"hash":"7aa9b83d6d2e186e34fb8e9e16f60a7aaa680f44","type":"INDEX","name":"ACH_TRANSFER_DETAILS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_TRANSFER_DETAILS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_TRANSFER_DETAILS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}