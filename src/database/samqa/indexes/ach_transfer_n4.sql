create index samqa.ach_transfer_n4 on
    samqa.ach_transfer (
        invoice_id
    );


-- sqlcl_snapshot {"hash":"9bf4c2443452dc81b779280e968869eec589123d","type":"INDEX","name":"ACH_TRANSFER_N4","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_TRANSFER_N4</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_TRANSFER</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}