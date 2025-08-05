create index samqa.ach_upload_staging_n1 on
    samqa.ach_upload_staging (
        batch_number
    );


-- sqlcl_snapshot {"hash":"693e3454a9ec47b44bd412eb0dc7a53d270a4d3e","type":"INDEX","name":"ACH_UPLOAD_STAGING_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_UPLOAD_STAGING_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_UPLOAD_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}