create index samqa.broker_payments_n2 on
    samqa.broker_payments (
        vendor_id
    );


-- sqlcl_snapshot {"hash":"e39fd9a845044795aba9d10b08640cb73d59cb7d","type":"INDEX","name":"BROKER_PAYMENTS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_PAYMENTS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BROKER_PAYMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>VENDOR_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}