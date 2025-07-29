create index samqa.ar_invoice_notifications_n1 on
    samqa.ar_invoice_notifications (
        invoice_id
    desc );


-- sqlcl_snapshot {"hash":"88f72ed4db5e589a3e9a2c965b4140b8b1667c57","type":"INDEX","name":"AR_INVOICE_NOTIFICATIONS_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_NOTIFICATIONS_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_NOTIFICATIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>\"INVOICE_ID\"</NAME>\n            <DESC></DESC>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}