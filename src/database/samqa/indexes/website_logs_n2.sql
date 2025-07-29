create index samqa.website_logs_n2 on
    samqa.website_logs (
        creation_date
    );


-- sqlcl_snapshot {"hash":"909349051c475ae0d33933e102abdab9f271a5e0","type":"INDEX","name":"WEBSITE_LOGS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>WEBSITE_LOGS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>WEBSITE_LOGS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CREATION_DATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}