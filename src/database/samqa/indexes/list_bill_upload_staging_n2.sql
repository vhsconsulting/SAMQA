create index samqa.list_bill_upload_staging_n2 on
    samqa.list_bill_upload_staging (
        list_bill_num
    );


-- sqlcl_snapshot {"hash":"cdb22dd75ce9e5ad2592c3c77188b7ae5e004ba6","type":"INDEX","name":"LIST_BILL_UPLOAD_STAGING_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>LIST_BILL_UPLOAD_STAGING_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>LIST_BILL_UPLOAD_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LIST_BILL_NUM</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}