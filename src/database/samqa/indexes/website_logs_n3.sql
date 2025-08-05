create index samqa.website_logs_n3 on
    samqa.website_logs (
        message
    );


-- sqlcl_snapshot {"hash":"44a7f51dc403134a6e827eceefa2322b868b8da9","type":"INDEX","name":"WEBSITE_LOGS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>WEBSITE_LOGS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>WEBSITE_LOGS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>MESSAGE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}