create index samqa.bill_format_staging_n1 on
    samqa.bill_format_staging (
        batch_number
    );


-- sqlcl_snapshot {"hash":"eddb3c83cd2228f3bbfa41bff9a15975797a7910","type":"INDEX","name":"BILL_FORMAT_STAGING_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BILL_FORMAT_STAGING_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BILL_FORMAT_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}