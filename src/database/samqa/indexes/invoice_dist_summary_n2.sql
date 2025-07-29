create index samqa.invoice_dist_summary_n2 on
    samqa.invoice_distribution_summary (
        entrp_id,
        pers_id
    );


-- sqlcl_snapshot {"hash":"fbbe13c1cd370cc6346eba1fc8f92a44d6820f5c","type":"INDEX","name":"INVOICE_DIST_SUMMARY_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>INVOICE_DIST_SUMMARY_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>INVOICE_DISTRIBUTION_SUMMARY</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>ENTRP_ID</NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>PERS_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}