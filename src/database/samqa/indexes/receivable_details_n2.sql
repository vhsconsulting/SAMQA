create index samqa.receivable_details_n2 on
    samqa.receivable_details (
        group_acc_id
    );


-- sqlcl_snapshot {"hash":"7b0c20e39b57e5333347f615c660d3ffe6e031b9","type":"INDEX","name":"RECEIVABLE_DETAILS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>RECEIVABLE_DETAILS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>RECEIVABLE_DETAILS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>GROUP_ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}