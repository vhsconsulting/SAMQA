create index samqa.bill_format_staging_n6 on
    samqa.bill_format_staging (
        ssn
    );


-- sqlcl_snapshot {"hash":"57feef1097d8ea3e80d91a8c1b9d2cbbc10c5aa9","type":"INDEX","name":"BILL_FORMAT_STAGING_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BILL_FORMAT_STAGING_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BILL_FORMAT_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}