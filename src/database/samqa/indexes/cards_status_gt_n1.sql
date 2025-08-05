create index samqa.cards_status_gt_n1 on
    samqa.cards_status_gt (
        employee_id
    );


-- sqlcl_snapshot {"hash":"04f1fd527c676716fe8c99b8e6d6078fb39db6c2","type":"INDEX","name":"CARDS_STATUS_GT_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CARDS_STATUS_GT_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>CARDS_STATUS_GT</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>EMPLOYEE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <INDEX_ATTRIBUTES></INDEX_ATTRIBUTES>\n   </TABLE_INDEX>\n</INDEX>"}