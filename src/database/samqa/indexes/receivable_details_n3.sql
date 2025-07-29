create index samqa.receivable_details_n3 on
    samqa.receivable_details (
        group_number
    );


-- sqlcl_snapshot {"hash":"884136cd94776f9d1031e7f7dc24c3006e8d2726","type":"INDEX","name":"RECEIVABLE_DETAILS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>RECEIVABLE_DETAILS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>RECEIVABLE_DETAILS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>GROUP_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}