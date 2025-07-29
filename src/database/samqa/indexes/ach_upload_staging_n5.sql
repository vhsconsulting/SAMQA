create index samqa.ach_upload_staging_n5 on
    samqa.ach_upload_staging (
        bank_name,
        bank_routing_num,
        bank_acct_num
    );


-- sqlcl_snapshot {"hash":"e03f9f51c258574a37b5bf95b85325b4b61ad3ae","type":"INDEX","name":"ACH_UPLOAD_STAGING_N5","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_UPLOAD_STAGING_N5</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_UPLOAD_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BANK_NAME</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>BANK_ROUTING_NUM</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>BANK_ACCT_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}