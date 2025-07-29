create index samqa.ach_upload_staging_n2 on
    samqa.ach_upload_staging (
        transaction_id
    );


-- sqlcl_snapshot {"hash":"58c2f9f3fb33ea9c9181979de9985fc8e1d9927d","type":"INDEX","name":"ACH_UPLOAD_STAGING_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_UPLOAD_STAGING_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_UPLOAD_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TRANSACTION_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}