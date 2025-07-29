create index samqa.invoice_dist_summary_n1 on
    samqa.invoice_distribution_summary (
        invoice_id
    );


-- sqlcl_snapshot {"hash":"0284a1bffaa18f2cd2636cbbe37acb7d5d1e0f9c","type":"INDEX","name":"INVOICE_DIST_SUMMARY_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_DIST_SUMMARY_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVOICE_DISTRIBUTION_SUMMARY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>INVOICE_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}