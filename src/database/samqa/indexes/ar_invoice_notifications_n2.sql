create index samqa.ar_invoice_notifications_n2 on
    samqa.ar_invoice_notifications (
        notification_id
    );


-- sqlcl_snapshot {"hash":"115f8239469f2f0762fe069f9cba1dd26b4560ef","type":"INDEX","name":"AR_INVOICE_NOTIFICATIONS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>AR_INVOICE_NOTIFICATIONS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>AR_INVOICE_NOTIFICATIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>NOTIFICATION_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}