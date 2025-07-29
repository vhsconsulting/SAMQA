create index samqa.bill_format_staging_n3 on
    samqa.bill_format_staging (
        grp_acc_id
    );


-- sqlcl_snapshot {"hash":"1935e1e1c48799d69a61d1631f9d5c30c343f339","type":"INDEX","name":"BILL_FORMAT_STAGING_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BILL_FORMAT_STAGING_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BILL_FORMAT_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>GRP_ACC_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}