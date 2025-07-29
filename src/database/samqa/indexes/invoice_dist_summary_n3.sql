create index samqa.invoice_dist_summary_n3 on
    samqa.invoice_distribution_summary (
        rate_code,
        account_type
    );


-- sqlcl_snapshot {"hash":"029906cba807188a76e8b87b399a7c98266a9aa9","type":"INDEX","name":"INVOICE_DIST_SUMMARY_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_DIST_SUMMARY_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVOICE_DISTRIBUTION_SUMMARY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>RATE_CODE</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>ACCOUNT_TYPE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}