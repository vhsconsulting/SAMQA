create index samqa.ach_transfer_details_n3 on
    samqa.ach_transfer_details (
        transaction_id,
        group_acc_id,
        acc_id
    );


-- sqlcl_snapshot {"hash":"a18d3d0696f04ac49b3e632bacc75a35b3ed8117","type":"INDEX","name":"ACH_TRANSFER_DETAILS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_TRANSFER_DETAILS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_TRANSFER_DETAILS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>GROUP_ACC_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}